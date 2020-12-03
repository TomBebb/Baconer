.import QtQuick 2.1 as Quick

function openLink(url) {
    Qt.openUrlExternally(url);
}

function isString(txt) {
    return typeof(txt) === 'string';
}
function isNonEmptyString(txt) {
    return isString(txt) && txt.length > 0;
}


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
    }

    return getRedditJSON(url, params).then(data => {
        let index = 0;
        for (const rawChild of data.data.children) {
            const child = rawChild.data;
            const previewData = child.preview;
            const previewDataImages = previewData ? previewData.images : null;

            let modelData = {
                index: index++,
                postTitle: child.title,
                postContent: child.selftext,
                author: child.author,
                score: child.score,
                thumbnail: child.thumbnail,
                commentCount: child.num_comments
            };

            if (previewDataImages !== null && previewDataImages.length > 0) {
                const chosenImage = previewDataImages[0]
                const chosenImageSource = chosenImage.source
                modelData.previewImage = chosenImageSource.url
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
        const frontPage = "Frontpage";
        subsModel.append({
            name: frontPage,
            title: frontPage,
            url: "/",
            description: "Front page of the internet"
        });

        for (let rawChild of data.data.children) {
            let child = rawChild.data;

            subsModel.append({
                name: child.display_name,
                title: child.title,
                url: child.url,
                description: tidyDescription(child.public_description)
            });
        }
                                                         acceptedButtons: Qt.LeftButton | Qt.RightButton

        return data;
    });
}

function resolveComponent(path) {
    console.log(`resolving comp: ${path}`);
    return new Promise((resolve, reject) => {
        const component = Qt.createComponent(path, Quick.Component.Asynchronous);

        if (component.status === Quick.Component.Ready) {
           resolve(component);
        } else {
           component.statusChanged.connect(() => {
               if (component.status === Quick.Component.Ready) {
                   resolve(component);
               } else if (component.status === Quick.Component.Error) {
                   reject(`Error loading component: ${component.errorString()}`);
               }
           });
        }
    });
}

function createComponent(path, props={}) {
    return resolveComponent(path).then(comp => comp.createObject(root, props));
}
