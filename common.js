.pragma library

function toString(obj) {
    if (obj === null)
        return "null";
    var txt;
    switch(typeof(obj)) {
        case "object":
            if (Array.isArray(obj)) {
                txt = "[";
                for (let i = 0; i < obj.length; i++) {
                    if (i > 0)
                        txt += ", ";
                    txt += toString(obj[i]);
                }
                return txt + "]";
            } else {
                txt = "{ ";
                for (const field of Object.keys(obj)) {
                    txt += `${field}: ${toString(obj[field])}, `;
                }
                return txt + " }";
            }
        default:
            return obj + "";
    }
}

function rawGet(url, params) {
    if (params) {
        url += "?";
        for (let key of Object.keys(params)) {
            url += `${encodeURI(key)}=${encodeURI(params[key])}&`;
        }
    }
    console.log(`expanded url: ${url}`);
    
    const xhr = new XMLHttpRequest();
    xhr.open("GET", url);
    xhr.timeout = 1000;
    xhr.send();

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

function getJSON(url, params) {
    return rawGet(url, params).then(JSON.parse);
}

function tidyDescription(text) {
    const newlines = /[\r\n]/;
    const newlineIndex = text.search(newlines);
    if (newlineIndex !== -1)
        text = text.substr(0, newlineIndex);

    return text;
}

function getRedditJSON(url, params) {
    return getJSON("https://api.reddit.com" + url, params);
}

function isFrontpage(data) {
    return data.url === "/";
}

function loadPosts(url, postsModel, after) {
    const params = {};
    
    params.raw_json = 1;

    if (after) {
        params.after = after;
        console.log("Load after params: "+toString(params));
    }

    return getRedditJSON(url, params).then(data => {

        if (!after)
            postsModel.clear();

        for (let rawChild of data.data.children) {
            let child = rawChild.data;
            const previewData = child.preview;
            const previewDataImages = previewData ? previewData.images : null;

            let modelData = {
                postTitle: child.title,
                postContent: child.selftext,
                author: child.author,
                score: child.score,
                thumbnail: child.thumbnail,
                commentCount: child.num_comments
            };
            modelData.previewImage = (previewDataImages === null || previewDataImages.length === 0) ? "" : previewDataImages[0].source.url;

            postsModel.append(modelData);
        }

        postsModel.after = data.data.after;
        postsModel.before = data.data.before;

        return data;
    });
}

function loadPostsAfter(url, postsModel) {
    if (postsModel.loadingPosts)
        return;
    postsModel.loadingPosts = true;
    const afterLoadCb = () => {
        postsModel.loadingPosts = false;
    };
    return loadPosts(url, postsModel, postsModel.finalId)
        .then(afterLoadCb, afterLoadCb);
}

function loadSubs(subsModel) {
    return getRedditJSON("/subreddits/default").then(data => {
        subsModel.clear();
        subsModel.append({
            name: "Frontpage",
            url: "/",
            description: "Front page of the internet"
        });

        for (let rawChild of data.data.children) {
            let child = rawChild.data;

            subsModel.append({
                name: child.display_name,
                url: child.url,
                description: tidyDescription(child.public_description)
            });
        }
        return data;
    });
}
