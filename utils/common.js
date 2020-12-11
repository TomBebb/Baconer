.import QtQuick 2.1 as Quick
.import org.kde.kirigami 2.13 as Kirigami

const redditRegex = /^(?:https?:\/\/)?(?:old\.|www\.)?reddit.com/;
const subRedditRegex = /^\/r\/([a-zA-Z-_]+)\/?/;
const postRegex = /^\/r\/([a-zA-Z-_]+)\/comments\/([a-zA-Z0-9]+)\/?/;
const urlHashArgRegex = /(?:\#|&|;)([^=]+)=([^&|;]+)/g;
const urlArgRegex = /(?:\?|&|;)([^=]+)=([^&|;]+)/g;
const clientID = "QwuPozK5cW9cwA";
const redirectURI = "http://locahost:8042/redirect";


function convertColor(color, isBg) {
    if (color == null || color.length === 0)
        return isBg ? "white" : "black";
    switch(color) {
        case "dark": return "black";
        case "light": return "white";
        default: return color;
    }
}

function parseURL(url) {
    let hashArgs = {};
    let urlArgs = {};
    let matches = [];

    const hashIndex = url.indexOf("#");
    if (hashIndex !== -1) {
        let hash = url.substr(hashIndex);
        url = url.substr(0, hashIndex);


        while (true) {
            matches = urlHashArgRegex.exec(hash);
            if (!matches)
                break;
            hashArgs[matches[1]] = matches[2];
        }
    }
    while (true) {
        matches = urlArgRegex.exec(url);
        if (!matches)
            break;
        urlArgs[matches[1]] = matches[2];
    }
    const questionIndex = url.indexOf("?");
    if (questionIndex !== -1)
        url = url.substr(0, questionIndex);
    return {url: url, args: urlArgs, hash: hashArgs};

}

function nodeToStr(node) {
    if (node.id && node.id.length > 0)
        return node.id;
    if (node.objectName && node.objectName.length > 0)
        return node.objectName;

    return "????";
}

function setAll(node, field, value) {

    forAllIn(node, obj => {
        const preValue = obj[field];
        if (preValue !== null && preValue !== undefined)
            obj[field] = value;
    });
}

function getPage(node) {
    console.debug(`find page for: ${nodeToStr(node)}`);
    while (node && !(node instanceof Kirigami.Page)) {
        console.debug(`finding page for: ${nodeToStr(node)}`);
        node = node.parent;
    }
    return node;
}

function decodeHtml(text) {
    return text.replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">");
}

function decodeHtml(text) {
    return text.replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">");
}

function forAllIn(obj, func) {
    const objectsToProcess = [obj];

    while (objectsToProcess.length > 0) {
        const curr = objectsToProcess.pop();
        if (typeof curr !== "object")
            continue;

        func(curr);

        if (curr.contentItem)
            objectsToProcess.push(curr.contentItem);

        if (curr.children && curr.children.length > 0)
            for (let i = 0; i < curr.children.length; i++) {
                objectsToProcess.push(curr.children[i]);
            }
    }
}

function formatNum(num) {

    if (num < 1000)
        return qsTr("%1").arg(num);

    if (num < 1000000)
        return qsTr("%L1K").arg(Math.round(num / 1000));

    if (num < 1000000000)
        return qsTr("%L1M").arg(Math.round(num / 1000000));

    return qsTr("%L1B").arg(Math.round(num / 1000000000));
}

function formatScore(num) {
    return formatNum(Math.abs(num), num < 0 ? "-" : "+");
}

function fromUtcRaw(utcSecs) {
    const d = new Date(0);
    d.setUTCSeconds(utcSecs);
    return d;
}

function makeURLParams(params) {
    let url = "";
    for (let key of Object.keys(params)) {
        url += `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}&`;
    }
    return url;
}

function makeURLFromParts(url, params) {
    if (params) {
        if (url.indexOf("?") === -1)
            url += "?";
        url += makeURLParams(params);
    }
    return url;
}

function genAuthorizeURL(scopes, state){

    return makeURLFromParts("https://www.reddit.com/api/v1/authorize", {
        client_id: clientID         ,
        response_type:  "token",
        state: state,
        redirect_uri: redirectURI,
        scope: scopes.join(" ")
    });
}


function chooseImageSource(previewImages) {

    switch (settingsPage.imagePreviewChoiceName) {
        case "min":
            return previewImages[0];
        case "max":
            return previewImages[previewImages.length - 1];

    }
    return previewImages[previewImages.length - 1];
}

function pluralize(amount, unit) {
    return qsTr("%L1 %2").arg(amount | 0).arg(unit);
}

function timeSince(date) {
    const seconds = Math.floor((Date.now() - date) / 1000);
    let interval = seconds / 31536000;

    if (interval > 1) {
        return pluralize(interval, "years");
    }
    interval = seconds / 2592000;
    if (interval > 1) {
        return pluralize(interval, "months");
    }
    interval = seconds / 86400;
    if (interval > 1) {
        return pluralize(interval, "days");
    }
    interval = seconds / 3600;
    if (interval > 1) {
        return pluralize(interval, "hours");
    }
    interval = seconds / 60;
    if (interval > 1) {
        return pluralize(interval, "mins");
    }

    return pluralize(interval, "secs");
}

function charAt(text, index) {
    if (typeof text !== "string")
        throw `charAt expects text, got ${typeof text}`;
    if (typeof index !== "number")
        throw "charAt expects num";
    return text.substr(index, 1);
}
function isLowerCase(char) {
    if (typeof char !== "string")
        throw `isLowerCase expects text, got ${typeof text}`;
    return char.toLowerCase() === char;
}
function isUpperCase(char) {
    return !isLowerCase(char);
}

function startsWith(text, sub) {
    return text.indexOf(sub) === 0;
}
function endsWith(text, sub) {
    return text.indexOf(sub, text.length - sub.length) !== -1;
}

function openRedditLink(url) {
    const redditUrl = url.replace(redditRegex, "");
    const subRedditMatch = redditUrl.match(subRedditRegex);
    const page = root.pageStack.currentItem;

    if (subRedditMatch && subRedditMatch.length >= 2) {
        const name = subRedditMatch[1];
        const subRedditUrl = `/r/${name}`;

        if (page.objectName === "postsPage" && page.url.toLowerCase() === subRedditUrl.toLowerCase()) {
            return Promise.resolve({});
        }

        return createComponent("/pages/PostsPage.qml", {url: `/r/${name}`});
    }
    const postMatch = redditUrl.match(postRegex);
    return null;
}
function openLink(url) {
    console.debug(`open link: ${url}`);
    const redditPageForLink = openRedditLink(url);
    if (redditPageForLink) {
        return redditPageForLink.then(page => {
            root.openPage(page);
            return page;
        }).catch(err => console.error("Error opening reddit link: "+err));
    }

    if (url.indexOf("://") === -1)
        url = "http://" + url;

    if (settingsPage.settings.preferExternalBrowser) {
        Qt.openUrlExternally(url);
    } else {
        return createComponent("/pages/WebPage.qml", {initialURL: url}).then(page => {
            console.log("Page made");
            root.openPage(page);
            return page;
        });
    }

    return Promise.resolve({});
}

function searchValuesFor(obj, txt, caseSensitive=true) {
    if (!caseSensitive)
        txt = txt.toLowerCase();
    for (let val of Object.values(obj)) {
        val += "";
        if (!caseSensitive)
            val = val.toLowerCase();
        if (val.includes(txt))
            return true;
    }
    return false;
}

function isString(txt) {
    return typeof(txt) === 'string';
}
function isNonEmptyString(txt) {
    return isString(txt) && txt.length > 0;
}

function tidyDescription(text, maxLength = 255) {
    text = decodeHtml(text);
    const newlines = /[\r\n]/;
    const newlineIndex = text.search(newlines);
    if (newlineIndex !== -1)
        text = text.substr(0, newlineIndex);


    if (text.length > maxLength)
        text = text.substr(0, maxLength - 3) + "...";
    return text;
}

function isFrontpage(data) {
    return data.url === "/";
}

function statusToString(status) {
    switch(status) {
        case Quick.Component.Null: return "null";
        case Quick.Component.Ready: return "ready";
        case Quick.Component.Loading: return "loading";
        case Quick.Component.Error: return "error";
    }
    return "???";
}

function randomString(len = 10) {
    let result = "";
    const chars = "abcdefghijklmnopqrstuvqxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (let i  = 0; i < len; i++)
        result += charAt(chars, Math.floor(chars.length * Math.random()));
    return result;
}

function resolveComponent(path) {
    return new Promise((resolve, reject) => {
        console.debug(`Creating component: ${path}`);
        const component = Qt.createComponent(path, Quick.Component.Asynchronous);

        if (component.status === Quick.Component.Ready) {
           resolve(component);
        } else {
           console.debug(`Waiting for ready: ${path}`);

           component.statusChanged.connect(() => {
                console.debug(`${path} status: ${statusToString(component.status)}`);
               if (component.status === Quick.Component.Ready) {
                console.debug(`${path} ready`);
                   resolve(component);
               } else if (component.status === Quick.Component.Error) {
                   reject(`Error loading component: ${component.errorString()}`);
               } else if (component.status === Quick.Component.Loading) {
                    console.debug(`${url} loading`);
               }
           });


        }
    }).catch(err => console.error("error resolving comp:" +err));
}

function createComponent(path, props={}) {
    return resolveComponent(path).then(comp => {
        console.debug(`Creating object for: ${path} ${comp}`);
        const obj = comp.createObject(root, props);
        console.debug("Created object");
        return obj;
    }).catch(err => console.error("error making comp: "+err));
}
