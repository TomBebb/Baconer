.import "common.js" as Common

const redditIcon = {
    source: "qrc:///images/reddit.png",
    width: 32,
    height: 32
};

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
    const previewDataVideo = previewData ? previewData.reddit_video_preview : null;


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
        previewVideo: {isValid: false},
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
    if (previewDataVideo) {
        modelData.previewVideo = {
            isValid: true,
            lowRes: previewDataVideo.scrubber_media_url,
            highRes: previewDataVideo.fallback_url,
            isGif: previewDataVideo.is_gif,
            duration: previewDataVideo.duration,
            width: previewDataVideo.width,
            height: previewDataVideo.height
        }
        console.debug(JSON.stringify(modelData.previewVideo));
    }

    modelData.numFlairs = modelData.flairs.length;

    return modelData;
}

function convertComment(rawChild) {
    const child = rawChild.data;
    if (!child.body)
        return null;

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
        url: child.path,
        itemIcon: redditIcon,
        hasHeader: rawChild.hasHeader || false
    };

    if (rawChild.hasHeader)
        multiData.headerImage = rawChild.headerImage;

    if (child.icon_img) {

        multiData.itemIcon = {
            source: child.icon_img
        }
    }

    return multiData;
}

function convertSub(rawChild)  {
    let child = rawChild;
    if (child.data)
        child = child.data;
    const headerSize = child.header_size;
    const subData = {
        name: child.display_name,
        title: child.title,
        url: child.url,
        description: Common.tidyDescription(child.public_description),
        fullDescription: Common.isNonEmptyString(child.description) ? Common.decodeHtml(child.description) : "",
        submitText: Common.isNonEmptyString(child.submit_text) ? Common.decodeHtml(child.submit_text) : qsTr("Submit post"),
        subscribers: child.subscribers,
        hasHeader: false,
        headerImage: {},
        lang: child.lang,
        itemIcon: redditIcon,
        colors: {},
        subscribed: false
    };


    if (headerSize && headerSize.length === 2 && Common.isNonEmptyString(child.header_img)) {
        subData.hasHeader = true;
        subData.headerImage = {
            source: child.header_img,
            width: headerSize[0],
            height: headerSize[1]
        };
    }

    console.debug("HEADER: "+JSON.stringify(subData.headerImage));

    if (rawChild.user_is_subscriber)
        subData.subscribed = rawChild.user_is_subscriber;

    if (child.icon_img && child.icon_size) {

        subData.itemIcon = {
            source: child.icon_img,
            width: child.icon_size[0],
            height: child.icon_size[1]
        }
    }

    return subData;
}
