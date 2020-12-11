import QtQuick 2.0
import "common.js" as Common
import "dataConverters.js" as DataConverters
import "../utils"

Item {
    property var cache: new Map()

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

    function rawGet(url, params, forceRefresh, timeout) {
        if (params) {
            if (url.indexOf("?") === -1)
                url += "?";
            else if (url.charAt(url.length - 1) !== "&")
                url += "&";

            for (let key of Object.keys(params)) {
                url += `${encodeURI(key)}=${encodeURI(params[key])}&`;
            }
            if (url.charAt(url.length - 1) === "&")
                url = url.substr(0, url.length - 1);
        }

        const xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.setRequestHeader("User-Agent", "Baconer by TopHattedCoder");
        xhr.send();

        console.debug(`get ${url}`);

        if (forceRefresh) {
            cache.delete(url);
        }

        if (cache.has(url)) {
            return Promise.resolve(cache.get(url));
        }

        return new Promise(function(resolve, reject) {
            xhr.onreadystatechange = function() {
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

    function getJSON(url, params, forceRefresh = false, timeout = 5000) {
        return rawGet(url, params, forceRefresh, timeout)
            .then(resp => JSON.parse(resp));
    }


    function getRedditJSON(url, params, forceRefresh = false) {
        return getJSON("https://api.reddit.com" + url, params, forceRefresh);
    }


    function loadPosts(url, postsModel, after, forceRefresh = false) {
        console.log(`loadPosts: ${url}, ${postsModel}, ${after}`);
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
        }).catch(err => console.error(`Error loading posts: ${err}`));
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
                subItem.isFavorite = settingsPage.settings.favorites.has(subItem.url)
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
        return getRedditJSON("/subreddits/default", null, forceRefresh).then(data => {
            const subs = [];
            const frontPage = "Frontpage";

            const favorites = settingsPage.settings.favorites;

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
}
