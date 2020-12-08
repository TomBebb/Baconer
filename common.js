.import QtQuick 2.1 as Quick

const redditRegex = /(?:https?)?(?:old\.|www\.)?reddit.com/;
const subRedditRegex = /^\/r\/([a-zA-Z-_]+)\/?/;
const postRegex = /^\/r\/([a-zA-Z-_]+)\/comments\/([a-zA-Z0-9]+)\/?/;

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

function formatNum(num) {

    if (num < 1000)
        return num;

    if (num < 1000000)
        return `${Math.round(num / 1000)}K`;

    if (num < 1000000000)
        return `${Math.round(num / 1000000)}M`;

    return `${Math.round(num / 1000000)}B`;
}

function formatScore(num) {
    return formatNum(Math.abs(num), num < 0 ? "-" : "+");
}

function fromUtcRaw(utcSecs) {
    const d = new Date(0);
    d.setUTCSeconds(utcSecs);
    return d;
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

function openLink(url) {
    const redditUrl = url.replace(redditRegex, "");
    const subRedditMatch = redditUrl.match(subRedditRegex);

    if (subRedditMatch && subRedditMatch.length >= 2) {
        const name = subRedditMatch[1];
        createComponent("/pages/PostsPage.qml", {url: `/r/${name}`}).then(page => {
            root.pageStack.push(page);
        });
        return;
    }

    const postMatch = redditUrl.match(postRegex);
    console.log(`Post match: ${toString(postMatch)}`);
    if (url.indexOf("://") === -1)
        url = "http://" + url;

    if (settingsPage.settings.preferExternalBrowser) {
        Qt.openUrlExternally(url);
    } else {
        createComponent("/pages/WebPage.qml", {initialURL: url}).then(page => {
            root.pageStack.push(page);
        });
    }
}

function isString(txt) {
    return typeof(txt) === 'string';
}
function isNonEmptyString(txt) {
    return isString(txt) && txt.length > 0;
}

function tidyDescription(text, maxLength = 255) {
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

function resolveComponent(path) {
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
