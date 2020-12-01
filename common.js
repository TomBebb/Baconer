.pragma library

function getJSON(url) {
  var xhr = new XMLHttpRequest;
  xhr.open("GET", url);
  xhr.send();

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
        console.log(`Got posts data: ${url} => ${data.data.children.length}`);

        for (let rawChild of data.data.children) {
            let child = rawChild.data;
            console.log(`loading post: ${child.title}`);
            const previewData = child.preview;
                                    console.log(`loading post images: ${child.title}`);
            const previewDataImages = previewData ? previewData.images : null;

                                    console.log(`loading post data: ${child.title}`);

            let modelData = {
                postTitle: child.title,
                postContent: child.selftext,
                author: child.author,
                score: child.score,
                thumbnail: child.thumbnail,
                commentCount: child.num_comments
            };
                                    console.log(`Getting preview`);
            modelData.previewImage = (previewDataImages === null || previewDataImages.length === 0) ? "" : fixURL(previewDataImages[0].source.url);
                                    console.log(`gOT preview`);

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
                                                      name: "AskReddit",
                                                      url: "/r/askreddit",
                                                      description: "Ask"
                                                  });

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
