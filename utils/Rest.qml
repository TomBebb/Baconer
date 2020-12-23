import QtQuick 2.12
import "common.js" as Common
import "dataConverters.js" as DataConv
import "../utils"

Item {
    id: rest
    property string accessToken
    property var accessTokenExpiry
    property var subInfoCache: new Map()
    property var cache: new Map()

    onAccessTokenChanged: settingsDialog.settings.accessToken = accessToken
    onAccessTokenExpiryChanged: settingsDialog.settings.accessTokenExpiry = accessTokenExpiry


    property bool isLoggedIn: accessToken != null && Date.now() < accessTokenExpiry
    onIsLoggedInChanged: {
        console.debug(`Logged in changed: ${isLoggedIn}`);

        clearCache();
        root.reload();
    }
    property string baseURL: isLoggedIn ? "https://oauth.reddit.com" : "https://api.reddit.com";

    Timer {
        interval: 1000 * 60 // every min
        running: true
        repeat: true
        onTriggered: {

            if (isLoggedIn && Date.now() > accessTokenExpiry) {
                console.debug("Log-in token expired");
                isLoggedIn = false;
            }

            for (let [url, data] of cache) {
                const sinceCachedMs = Date.now() - data.time;
                if (sinceCachedMs > settingsDialog.cacheTimeout * 1000) {
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

    function clearCache() {
        cache.clear();
        subInfoCache.clear();
    }

    function rawGet(url, params = {}, forceRefresh = false, timeout = 5000, useCache = false) {
        url = urlUtils.generateUrl(url, params);

        if (useCache && !forceRefresh && cache.has(url)) {
            const cached = cache.get(url);
            if (cached instanceof Promise)
                return cached;
            return Promise.resolve(cached);
        }

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        setDefaultHeaders(xhr);
        xhr.send();

        const result = new Promise(function(resolve, reject) {
            xhr.onreadystatechange = function() {
                // console.debug(`${url} GET State changed: readyState=${xhr.readyState} status=${xhr.status}`);
                if (xhr.readyState !== XMLHttpRequest.DONE)
                    return;

                if (xhr.status >= 200 && xhr.status < 300) {
                    ;
                    resolve(xhr.responseText);
                } else {
                    cache.delete(url);
                    reject({
                        url: url,
                        status: xhr.status,
                        statusText: xhr.statusText,
                    });
                }
            };
        });

        if (useCache) {
            result
                .then(txt => cache.set(url, txt))
                .catch(err => cache.delete(url));
            cache.set(url, result);
        }

        return result;
    }

    function rawPost(url, params = {}, postParams = {}, timeout = 5000) {
        url = urlUtils.generateUrl(url, params);


        const xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        const userNameAndPassword = Common.clientID + ":";

        if (url.indexOf("access_token") !== -1) {
            xhr.setRequestHeader("Authorization", `Basic ${Qt.btoa(userNameAndPassword)}`);
        } else {

            setDefaultHeaders(xhr);
        }

        console.debug(`POST ${url} w/ ${JSON.stringify(postParams)}`);

        xhr.send(postParams ? urlUtils.combineUrlParams(postParams) : undefined);

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

    function getJSON(url, params, forceRefresh, timeout, useCache) {
        return rawGet(url, params, forceRefresh, timeout, useCache)
            .then(resp => JSON.parse(resp));
    }
    function postJSON(url, params, postParams, timeout) {
        return rawPost(url, params, postParams, timeout)
            .then(resp => JSON.parse(resp));
    }


    function getRedditJSON(url, params, forceRefresh, timeout, useCache) {
        return getJSON(baseURL + url, params, forceRefresh, timeout, useCache);
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
    function subscribe(subName, sub = true) {
        return postJSON(`${baseURL}/api/subscribe`, null, {
            action: sub ? "sub" : "unsub",
            action_source: "n",
            sr_name: subName
        }).catch(err => console.error(`Error subscribing: ${JSON.stringify(err)}`));
    }

    function loadPosts(url, postsModel, after, forceRefresh = false) {
        const params = {};

        params.raw_json = 1;

        if (after) {
            params.after = after;
        }
        const isSub = stringUtils.startsWith(url, "/r/");

        return getRedditJSON(url, params, forceRefresh).then(data => {
            if (!after)
                postsModel.clear();

            const posts = [];
            for (const rawChild of data.data.children) {
                const child = DataConv.convertPost(rawChild);
                child.postIndex = postsModel.count;
                posts.push(child);
            }

            postsModel.after = data.data.after
            postsModel.before = data.data.before

            return posts
        }).then(posts => {
            for (const post of posts) {
                postsModel.append(post);
            }
            return posts;
        })
        .catch(err => console.error(`Error loading posts: ${JSON.stringiy(err)}`));
    }

    function loadPostsAfter(url, postsModel, forceRefresh) {
        console.debug("load posts after");
        return loadPosts(url, postsModel, postsModel.after, forceRefresh);
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
                    const modelData = DataConv.convertComment(rawChild);
                    if (modelData === null)
                        continue;
                    commentsModel.append(modelData);
                }
            }
        }).then(afterLoadCb, afterLoadCb);
    }
    function loadSubInfo(url, forceRefresh = false) {
        let infoUrl = url + "";
        if (url.charAt(url.length - 1) === '/')
            infoUrl = infoUrl.substr(0, infoUrl.length - 1);
        else
            url += "/";

        // console.debug(`url=${url}: in stored=${subInfoCache.has(url)}; stored: `+ Array.from(subInfoCache.keys()).join(", "));
        if (subInfoCache.has(url)) {
            const data = subInfoCache.get(url);
            if (data instanceof Promise)
                return data;
            return Promise.resolve(subInfoCache.get(url));
        }
        const result = getRedditJSON(`${infoUrl}/about`, {}, false, false)
            .then(rawData => {
                // console.debug(`got url=${url}: in stored=${subInfoCache.has(url)}; stored: `+ Array.from(subInfoCache.keys()).join(", "));
                const data = DataConv.convertSub(rawData.data);
                subInfoCache.set(url, data);
                return data;
             })
            .catch(raw => {
                console.error(`info error: ${raw}`);
                subInfoCache.delete(url);
            });
        subInfoCache.set(url, result);
        return result;
    }

    function loadDrawerItems(subsModel, forceRefresh) {
        console.debug(`loadDrawerItems`);

        return loadSubs(forceRefresh).then(rawSubItems => {

            let multiItems = [];
            let subItems = [];
            let favItems = [
                {
                    isFavorite: true,
                    isVisible: true,
                    name: "Frontpage",
                    title: "Frontpage",
                    url: "/",
                    description: "Front page of the internet",
                    isSub: false
                }
            ];
            for (const subItem of rawSubItems) {

                subItem.isVisible = true;
                subItem.isFavorite = settingsDialog.isFav(subItem.url);
                subItem.category =  subItem.isFavorite ? qsTr("Favorites") : qsTr("Subreddits");
                subItem.isSub = true;

                (subItem.isFavorite ? favItems : subItems).push(subItem);
            }

            if (rest.isLoggedIn) {
                return loadMultis(forceRefresh).then(rawMultiItems => {
                    for (const multiItem of rawMultiItems) {
                        multiItem.isVisible = true;
                        multiItem.isFavorite = settingsDialog.isFav(multiItem.url);
                        multiItem.category =  multiItem.isFavorite ? qsTr("Favorites") : qsTr("Multireddits");
                        multiItem.isSub = false;

                        (multiItem.isFavorite ? favItems : multiItems).push(multiItem);

                        return favItems.concat(multiItems).concat(subItems);
                    }
                });
            }

            return favItems.concat(multiItems).concat(subItems);
        }).then(items => {
            subsModel.clear();

            for (const item of items) {
                subsModel.append(item);
            }
            return items;
        });
    }

    function loadMultis(forceRefresh) {
        return getRedditJSON("/api/multi/mine").then(rawMultis => {
            const multis = [];

            for (const rawChild of rawMultis) {
                multis.push(DataConv.convertMulti(rawChild));
            }

            return multis;
        });
    }

    function loadSubs(forceRefresh) {
        const path = isLoggedIn ? "/subreddits/mine/subscriber" : "/subreddits/default";
        return getRedditJSON(path, null, forceRefresh).then(data => {
            const subs = [];

            for (const rawChild of data.data.children) {
                const subData = DataConv.convertSub(rawChild);
                subInfoCache.set(subData.url, subData);
                subs.push(subData);
            }

            return subs;
        }).catch(err => console.error(`Error fetching subs: ${err}`));
    }

    function searchSubs(query) {
        return getRedditJSON("/subreddits/search", {q: query}).then(data => {
            const subs = [];
            for (const rawChild of data.data.children) {
                const subData = DataConv.convertSub(rawChild);
                subs.push(subData);
                subInfoCache.set(subData.url, subData);
            }
            return subs;
        });
    }

    function tryOembed(url) {
        const twitterPostRegex = /^https?:\/\/twitter\.com\/(?:#!\/)?(\w+)\/status(es)?\/(\d+)/;
        const youtubeVidRegex = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?/;
        const youtubeVidMatchResult = url.match(youtubeVidRegex);

        if (twitterPostRegex.test(url)) {
            return getJSON("https://publish.twitter.com/oembed", {url: url}, true, null, false);
        } else if (youtubeVidMatchResult) {
            // group 5
            return Promise.resolve({
                url: urlUtils.generateUrl("https://www.youtube.com/embed/"+youtubeVidMatchResult[5],{
                        allowfullscreen:1,
                        autoplay: 1
                }),
                version: "1.0",
                type: "video",
                width: null,
                height: null,
                title: null,
                author_name: null,
                author_url: null,
                provider_name: "YouTube",
                provider_url: "https://www.youtube.com"
            });
        }

        return Promise.resolve(null);
    }

    function authorize(scopes){
        const state = stringUtils.randomString();
        scopes = [
            "identity", "edit", "flair", "history", "mysubreddits", "privatemessages", "read", "report", "save", "submit",
            "subscribe", "vote", "wikiread"
        ];
        const url = Common.genAuthorizeURL(scopes, state);

        Common.openLinkWebView(url).then(webPage => {
            const view = webPage.webView;
            view.urlChanged.connect(() => {
                const urlText = view.url.toString();
                if (stringUtils.startsWith(urlText, Common.redirectURI)) {
                    const urlDetails = urlUtils.parseUrl(urlText);
                    const hashArgs = urlDetails.hashArgs;

                    if (hashArgs.state !== state)
                        console.error(`State mismatch from reddit: ${urlDetails.hashArgs.state} != ${state}`);

                    // TODO: handle error

                    const expireTime = new Date();
                    expireTime.setSeconds(expireTime.getSeconds() + (hashArgs.expires_in | 0));

                    accessTokenExpiry = expireTime;
                    accessToken = hashArgs.access_token.toString();
                    isLoggedIn = true;

                    root.closePage(webPage);
                }
            });
        });
    }
}
