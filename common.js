.pragma library

function getJSON(url) {
  var xhr = new XMLHttpRequest;
  xhr.open("GET", url);
  xhr.send();

  console.log(url);

  return new Promise(function(resolve, reject) {
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return;

        if (xhr.status >= 200 && xhr.status < 300) {
            resolve(JSON.parse(xhr.responseText));
        } else {
            reject({
                url: url,
                status: xhr.status,
                statusText: xhr.statusText,
            });
        }
      }
  });
}

function tidyDescription(text) {
    const newlines = /[\r\n]/;
    const newlineIndex = text.search(newlines);
    if (newlineIndex !== -1)
        text = text.substr(0, newlineIndex);

    return text;
}

function getRedditJSON(url) {
    return getJSON("https://api.reddit.com" + url);
}

function isFrontpage(data) {
    return data.url === "/";
}

function loadPosts(url, postsModel) {
    getRedditJSON(url).then(data => {
        postsModel.clear();

        for (let rawChild of data.data.children) {
            let child = rawChild.data;
            const modelData = {
                postTitle: child.title,
                postContent: child.selftext,
                author: child.author,
                score: child.score,
                thumbnail: child.thumbnail,
                commentCount: child.num_comments
            };

            const previewData = child.preview;
            const previewDataImages = previewData === null ? null : previewData.images;
            let previewUrl = (previewDataImages === null || previewDataImages.length === 0) ? "" : previewDataImages[0].source.url;

            if (previewUrl)
                previewUrl = fixURL(previewUrl);

            modelData.previewImage = previewUrl;

            postsModel.append(modelData);
        }
    });
}

function fixURL(url) {

    url = url.replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">");
    return url;
}

function loadSubs(subsModel) {

    getRedditJSON("/subreddits/default").then(data => {
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
    });
}
