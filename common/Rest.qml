import QtQuick 2.0
import "../common.js" as Common

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
            console.debug(`${url} force refresh`);
            cache.delete(url);
        }

        if (cache.has(url)) {
            console.debug(`${url} cached`);
            return Promise.resolve(cache.get(url));
        }
        console.debug(`get ${url}`);


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
        postsModel.loadingPosts = true;
        const afterLoadCb = () => {
            postsModel.loadingPosts = false;
        };

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
                    subreddit: child.subreddit,
                    postTitle: child.title,
                    postContent: child.selftext,
                    author: child.author,
                    score: child.score,
                    ups: child.ups,
                    downs: child.downs,
                    thumbnail: Common.decodeHtml(child.thumbnail),
                    commentCount: child.num_comments
                };

                if (previewDataImages !== null && previewDataImages.length > 0) {
                    const chosenImage = previewDataImages[0]
                    const chosenImageSource = chosenImage.source
                    modelData.previewImage = Common.decodeHtml(chosenImageSource.url)
                    modelData.imageWidth = chosenImageSource.width
                    modelData.imageHeight = chosenImageSource.height
                } else {
                    modelData.previewImage = ""
                }

                postsModel.append(modelData)
            }

            postsModel.after = data.data.after
            postsModel.before = data.data.before

            return data
        }).then(afterLoadCb, afterLoadCb);
    }

    function loadPostsAfter(url, postsModel, forceRefresh) {
        if (postsModel.loadingPosts)
            return;
        postsModel.loadingPosts = true;
        const afterLoadCb = () => {
            postsModel.loadingPosts = false;
        };
        return loadPosts(url, postsModel, postsModel.finalId, forceRefresh)
            .then(afterLoadCb, afterLoadCb);
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
                        commentId: child.commentId,
                        created: Common.fromUtcRaw(child.created)
                    };
                    commentsModel.append(modelData);
                }
            }
        }).then(afterLoadCb, afterLoadCb);
    }

    function loadSubs(subsModel, forceRefresh) {
        return getRedditJSON("/subreddits/default", null, forceRefresh).then(data => {
            subsModel.clear();
            const frontPage = "Frontpage";
            subsModel.append({
                kind: "",
                kindName: "",
                name: frontPage,
                title: frontPage,
                url: "/",
                description: "Front page of the internet"
            });

            for (let rawChild of data.data.children) {
                let child = rawChild.data;

                subsModel.append({
                    kind: "sub",
                    kindName: "Subreddits",
                    name: child.display_name,
                    title: child.title,
                    url: child.url,
                    description: Common.tidyDescription(child.public_description)
                });
            }

            return data;
        });
    }
}
