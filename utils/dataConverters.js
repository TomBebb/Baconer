.import "common.js" as Common

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
        created: Common.fromUtcRaw(child.created)
    };
}

function convertSub(rawChild)  {
    let child = rawChild;
    if (child.data)
        child = child.data;
    console.debug(`raw fullName: ${child.name}; raw subscribed: ${child.user_is_subscriber}`);
    const subData = {
        subscribed: child.user_is_subscriber,
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

    return subData;
}
