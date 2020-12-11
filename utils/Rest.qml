import QtQuick 2.0
import "common.js" as Common
import "dataConverters.js" as DataConverters
import "../utils"

Item {
    id: rest
    property string accessToken: settingsPage.settings.accessToken
    property var accessTokenExpiry: settingsPage.settings.accessTokenExpiry
    property var cache: new Map()


    property bool isLoggedIn: accessToken != null && Date.now() < accessTokenExpiry
    property string baseURL: isLoggedIn ? "https://oauth.reddit.com" : "https://api.reddit.com";

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {

            for (let [url, data] of cache) {
                const sinceCachedMs = Date.now() - data.time;
                if (sinceCachedMs > settingsPage.cacheTimeout * 1000) {
                    console.debug(`${url} cache timeout`);
                    cache.delete(url);
                }
            }
        }
    }

    function setDefaultHeaders(xhr) {
        const platform = Qt.platform.os;
        xhr.setRequestHeader("User-Agent", `${Qt.platform.os}: Baconer (by /u/TopHattedCoder)`);
        if (isLoggedIn)
            xhr.setRequestHeader("Authorization", `bearer ${rest.accessToken}`);


    }

    function rawGet(url, params, forceRefresh, timeout) {
        url = Common.makeURLFromParts(url, params);

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        setDefaultHeaders(xhr);
        xhr.send();

        if (forceRefresh) {
            cache.delete(url);
        }

        if (cache.has(url)) {
            return Promise.resolve(cache.get(url));
        }

        return new Promise(function(resolve, reject) {
            xhr.onreadystatechange = function() {
                console.debug(`${url} GET State changed: readyState=${xhr.readyState} status=${xhr.status}`);
                if (xhr.readyState !== XMLHttpRequest.DONE)
                    return;

                if (xhr.status >= 200 && xhr.status < 300) {
                    cache.set(url, xhr.responseText);
                    console.debug(`got: ${url}`);
                    resolve(xhr.responseText);
                } else {
                    reject({
                        url: url,
                        status: xhr.status,
                        statusText: xhr.statusText,
                    });
                }
            };
        });
    }

    function rawPost(url, params, postParams, timeout) {
        url = Common.makeURLFromParts(url, params);


        const xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        const userNameAndPassword = Common.clientID + ":";

        if (url.indexOf("access_token") !== -1) {
            xhr.setRequestHeader("Authorization", `Basic ${Qt.btoa(userNameAndPassword)}`);
        } else {

            setDefaultHeaders(xhr);
        }

        xhr.send(postParams ? Common.makeURLParams(postParams) : undefined);

        return new Promise(function(resolve, reject) {
            xhr.onreadystatechange = function() {
                if (xhr.readyState !== XMLHttpRequest.DONE)
                    return;

                if (xhr.status >= 200 && xhr.status < 300) {
                    resolve(xhr.responseText);
                } else {
                    reject({
                        url: url,
                        status: xhr.status,
                        statusText: xhr.statusText,
                    });
                }
            };
        });
    }

    function getJSON(url, params, forceRefresh = false, timeout = 5000) {
        return rawGet(url, params, forceRefresh, timeout)
            .then(resp => JSON.parse(resp));
    }
    function postJSON(url, params, postParams, timeout = 5000) {
        return rawPost(url, params, postParams, timeout)
            .then(resp => JSON.parse(resp));
    }


    function getRedditJSON(url, params, forceRefresh = false) {
        return getJSON(baseURL + url, params, forceRefresh);
    }

    function getScopes() {
        return getRedditJSON("/api/v1/scopes")
            .then(scopesData => {
                let scopes = [];
                for (const scope of Object.values(scopesData))
                    scopes.push(scope);
                return scopes;
            });
    }

    function setSaved(fullName, save = true) {
        const endPoint = save ? "save" : "unsave";
        return postJSON(`${baseURL}/api/${endPoint}`, null, {
            id: fullName
        }).catch(err => console.error(`Error saving post: ${JSON.stringify(err)}`));
    }

    function vote(fullName, dir = 1) {
        return postJSON(`${baseURL}/api/vote`, null, {
            id: fullName,
            dir: dir,
            rak: 2
        }).catch(err => console.error(`Error voting on post: ${JSON.stringify(err)}`));
    }

    function loadPosts(url, postsModel, after, forceRefresh = false) {
        const params = {};

        params.raw_json = 1;

        if (after) {
            params.after = after;
        }

        return getRedditJSON(url, params, forceRefresh).then(data => {
            if (!after)
                postsModel.clear();
            for (const rawChild of data.data.children) {
                const child = DataConverters.convertPost(rawChild);
                child.postIndex = postsModel.count;
                postsModel.append(child);
            }

            postsModel.after = data.data.after
            postsModel.before = data.data.before

            return data
        }).catch(err => console.error(`Error loading posts: ${JSON.stringiy(err)}`));
    }

    function loadPostsAfter(url, postsModel, forceRefresh) {
        if (postsModel.loadingPosts)
            return;
        return loadPosts(url, postsModel, postsModel.finalId, forceRefresh);
    }

    function loadComments(postData, commentsModel, forceRefresh) {
        commentsModel.loadingComments = true;
        const afterLoadCb = () => {
            commentsModel.loadingComments = false;
        };
        return getRedditJSON(`/r/${postData.subreddit}/comments/${postData.postId}`, null, forceRefresh).then(children => {
            commentsModel.clear();

            for (const rawRoot of children) {
                for (const rawChild of rawRoot.data.children) {
                    const modelData = DataConverters.convertComment(rawChild);
                    if (modelData === null)
                        continue;
                    commentsModel.append(modelData);
                }
            }
        }).then(afterLoadCb, afterLoadCb);
    }

    function loadDrawerItems(subsModel, forceRefresh) {
        return loadSubs(forceRefresh).then(rawSubItems => {

            let favItems = [];
            let subItems = [];
            let multiItems = [
                {
                    isFavorite: true,
                    isVisible: true,
                    category: qsTr("Multireddits"),
                    name: "Frontpage",
                    title: "Frontpage",
                    url: "/",
                    description: "Front page of the internet",
                    isSub: false
                }
            ];
            for (const subItem of rawSubItems) {

                subItem.isVisible = true;
                subItem.isFavorite = settingsPage.isFav(subItem.url);
                subItem.category =  subItem.isFavorite ? qsTr("Favorites") : qsTr("Subreddits");
                subItem.isSub = true;

                (subItem.isFavorite ? favItems : subItems).push(subItem);
            }

            return favItems.concat(multiItems).concat(subItems);
        }).then(items => {
            subsModel.clear();

            for (const item of items)
                subsModel.append(item);
        });
    }

    function loadSubs(forceRefresh) {
        const path = isLoggedIn ? "/subreddits/mine/subscriber" : "/subreddits/default";
        return getRedditJSON(path, null, forceRefresh).then(data => {
            const subs = [];
            const frontPage = "Frontpage";

            for (const rawChild of data.data.children) {
                const child = rawChild.data;
                const subData = {
                    name: child.display_name,
                    title: child.title,
                    url: child.url,
                    description: Common.tidyDescription(child.public_description),
                    fullDescription: Common.decodeHtml(child.description),
                    submitText: Common.decodeHtml(child.submit_text),
                    subscribers: child.subscribers,
                    lang: child.lang,
                    itemIcon: {},
                    colors: {}
                };

                if (child.icon_img && child.icon_size) {

                    subData.itemIcon = {
                        source: child.icon_img,
                        width: child.icon_size[0],
                        height: child.icon_size[1]
                    }
                }

                subs.push(subData);
            }

            return subs;
        });
    }

    function authorize(scopes){
        const state = Common.randomString();
        scopes = [
            "identity", "edit", "flair", "history", "mysubreddits", "privatemessages", "read", "report", "save", "submit",
            "subscribe", "vote", "wikiread"
        ];
        const url = Common.genAuthorizeURL(scopes, state);

        Common.openLink(url).then(webPage => {
            const view = webPage.webView;
            view.urlChanged.connect(() => {
                const urlText = view.url.toString();
                console.debug("Web url: "+urlText);
                if (Common.startsWith(urlText, Common.redirectURI)) {
                    const urlDetails = Common.parseURL(urlText);
                    const hashArgs = urlDetails.hash;
                    console.debug(JSON.stringifyhashArgs);

                    if (hashArgs.state !== state)
                        console.error(`State mismatch from reddit: ${hashArgs.state} != ${state}`);

                    // TODO: handle error

                    const expireTime = new Date();
                    expireTime.setSeconds(expireTime.getTime() / 1000 + hashArgs.expires_in);

                    settingsPage.settings.accessTokenExpiry = expireTime;
                    settingsPage.settings.accessToken = hashArgs.access_token.toString();

                    console.debug(`expires: ${expireTime}`);

                    root.closePage(webPage);
                }
            });
        });
    }
}
