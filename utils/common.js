.import QtQuick 2.1 as Quick
.import org.kde.kirigami 2.13 as Kirigami

const redditRegex = /^(?:https?:\/\/)?(?:old\.|www\.)?reddit\.com/;
const subRedditRegex = /^\/r\/([a-zA-Z-_]+)\/?/;
const postRegex = /^\/r\/([a-zA-Z-_]+)\/comments\/([a-zA-Z0-9]+)\/?/;
const urlHashArgRegex = /(?:\#|&|;)([^=]+)=([^&|;]+)/g;
const urlArgRegex = /(?:\?|&|;)([^=]+)=([^&|;]+)/g;
const clientID = "QwuPozK5cW9cwA";
const redirectURI = "http://locahost:8042/redirect";
const youtubeRegex = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|watch\?v=))([a-zA-Z0-9\-_]+)/;


function convertColor(color, isBg) {
    if (color === null || color.length === 0)
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

    switch (settingsDialog.imagePreviewChoiceName) {
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

        return createComponent("qrc:///pages/PostsPage.qml", {url: `/r/${name}`});
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

    const youtubeMatch = url.match(youtubeRegex);
    if (youtubeMatch && youtubeMatch.length >= 2 && !settingsDialog.settings.preferExternalBrowser) {
        console.debug("Youtube link, using embed instead...");
        url = `https://www.youtube.com/embed/${youtubeMatch[1]}`;
    }

    if (url.indexOf("://") === -1)
        url = "http://" + url;

    if (settingsDialog.settings.preferExternalBrowser) {
        Qt.openUrlExternally(url);
    } else {
        return openLinkWebView(url);
    }

    return Promise.resolve({});
}

function openLinkWebView(url) {
    return createComponent("qrc:///pages/WebPage.qml", {initialURL: url}).then(page => {
        console.log("Page made");
        root.openPage(page);
        return page;
    }).catch(err => console.error(`Error opening web page: ${url}`));
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

function createComponent(path, props={}, parent = root) {
    const comp = Qt.createComponent(path);
    const instance = comp.createObject(parent, props);

    return new Promise((resolve, reject) => {
        if (instance === null) reject(`Error creating object for: ${path}`);
        resolve(instance);
    });
}
