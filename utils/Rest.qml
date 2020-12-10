import QtQuick 2.0
import "common.js" as Common
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
        xhr.send();

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
                const child = rawChild.data;
                const previewData = child.preview;

                const previewDataImages = previewData ? previewData.images : null;


                let modelData = {
                    postId: child.id,
                    postIndex: postsModel.count,
                    date: Common.fromUtcRaw(child.created_utc),
                    subreddit: child.subreddit,
                    postTitle: child.title,
                    postContent: child.selftext,
                    author: child.author,
                    score: child.score,
                    ups: child.ups,
                    downs: child.downs,
                    thumbnail: Common.decodeHtml(child.thumbnail),
                    commentCount: child.num_comments,
                    previewImages: [],
                    previewImage: {isValid: false}
                };

                if (previewDataImages && previewDataImages.length > 0) {

                    const previewImages = previewDataImages.map(rawImageData => {
                        let images = [...rawImageData.resolutions];
                        images.push(rawImageData.source);

                        for (let resData of images)
                            resData.url = Common.decodeHtml(resData.url)
                        return images;
                    });
                    modelData.previewImage = Common.chooseImageSource(previewImages[0]);

                    modelData.previewImage.isValid = true;
                }

                postsModel.append(modelData)
            }

            postsModel.after = data.data.after
            postsModel.before = data.data.before

            return data
        });
    }

    function loadPostsAfter(url, postsModel, forceRefresh) {
        if (postsModel.loadingPosts)
            return;
        return loadPosts(url, postsModel, postsModel.finalId, forceRefresh);
    }

    function loadComments(postData, commentsModel, forceRefresh) {
        console.debug(`loadComments for ${postData.postId} in ${postData.subreddit}; force=${forceRefresh}`);
        commentsModel.loadingComments = true;
        const afterLoadCb = () => {
            commentsModel.loadingComments = false;
        };
        return getRedditJSON(`/r/${postData.subreddit}/comments/${postData.postId}`, null, forceRefresh).then(children => {
            commentsModel.clear();

            for (const rawRoot of children) {
                for (const rawChild of rawRoot.data.children) {
                    const child = rawChild.data;
                    if (!child.body)
                        continue;


                    let modelData = {
                        author: child.author,
                        body: child.body,
                        score: child.score,
                        commentId: child.id,
                        created: Common.fromUtcRaw(child.created)
                    };
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

                subs.push({
                    name: child.display_name,
                    title: child.title,
                    url: child.url,
                    description: Common.tidyDescription(child.public_description)
                });
            }

            return subs;
        });
    }
}
