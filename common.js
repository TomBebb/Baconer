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
        for (let rawChild of data.data.children) {
            let child = rawChild.data;
            postsModel.append({
                postTitle: child.title,
                postContent: child.selftext
            });
        }
    });
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
