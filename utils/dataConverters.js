.import "common.js" as Common

const redditIconPath = "qrc:///images/reddit.png";
const redditIconSize = 32;

function isValidFlair(flairText) {
    if (flairText.length <= 0)
        return false;

    const firstChar = flairText.substr(0, 1);
    const lastChar = flairText.substr(flairText.length - 1, 1);

    return firstChar !== ':' || lastChar !== ':';
}

function convertPost(rawChild) {
    const child = rawChild.data;
    const previewData = child.preview;

    const previewDataImages = previewData ? previewData.images : null;


    let modelData = {
        saved: child.saved,
        postId: child.id,
        fullName: child.name,
        date: Common.fromUtcRaw(child.created_utc),
        subreddit: child.subreddit,
        postTitle: child.title,
        postContent: child.selftext,
        author: child.author,
        score: child.score,
        ups: child.ups,
        downs: child.downs,
        thumbnail: Common.decodeHtml(child.thumbnail),
        url: child.url_overridden_by_dest ? Common.decodeHtml(child.url_overridden_by_dest): "",
        commentCount: child.num_comments,
        previewImages: [],
        previewImage: {isValid: false},
        flairs: []
    };


    if (child.link_flair_text &&  isValidFlair(child.link_flair_text)) {
        modelData.flairs.push({
            flairText: child.link_flair_text,
            type: child.link_flair_type,
            colors: {
                text: child.link_flair_text_color,
                bg: child.link_flair_background_color
            }
        });
    }

    if (child.author_flair_text && isValidFlair(child.author_flair_text)) {
        modelData.flairs.push({
            flairText: child.author_flair_text,
            type: child.author_flair_type,
            colors: {
                text: child.author_flair_text_color,
                bg: child.author_flair_background_color
            }
        });
    }

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
    modelData.numFlairs = modelData.flairs.length;

    return modelData;
}

function convertComment(rawChild) {
    const child = rawChild.data;
    if (!child.body)
        return null;


    console.debug(JSON.stringify(child));

    return {
        author: child.author,
        body: child.body,
        score: child.score,
        commentId: child.id,
        date: Common.fromUtcRaw(child.created_utc),
        fullName: child.name
    };
}

function convertMulti(rawChild) {
    let child = rawChild;
    if (child.data)
        child = child.data;

    const multiData = {
        name: child.name,
        title: child.display_name,
        displayName: child.display_name,
        url: child.path
    };

    if (child.icon_img) {

        multiData.itemIcon = {
            source: child.icon_img
        }
    } else {
        multiData.itemIcon = {
            source: redditIconPath,
            width: redditIconSize,
            height: redditIconSize
        };
    }

    return multiData;
}

function convertSub(rawChild)  {
    let child = rawChild;
    if (child.data)
        child = child.data;
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
        colors: {},
        subscribed: false
    };

    if (rawChild.user_is_subscriber)
        subData.subscribed = rawChild.user_is_subscriber;

    if (child.icon_img && child.icon_size) {

        subData.itemIcon = {
            source: child.icon_img,
            width: child.icon_size[0],
            height: child.icon_size[1]
        }
    } else {
        subData.itemIcon = {
            source: redditIconPath,
            width: redditIconSize,
            height: redditIconSize
        };
    }

    return subData;
}
