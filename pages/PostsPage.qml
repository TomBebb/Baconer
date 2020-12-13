import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "../utils/common.js" as Common
import "../utils/dataConverters.js" as DataConv
import "../common"
import "../overlays"

Kirigami.ScrollablePage {
    property ListModel model: postsView.model
    property string url: subsView.currentURL
    property string sortUrl: changeSortOverlay.selectedSortUrl
    property bool isSubreddit: url.indexOf("/r/") === 0;
    property var info: null
    objectName: "postsPage"

    title: url

    Layout.fillWidth: true

    onSortUrlChanged: refresh()

    Component.onCompleted: {
        refresh();
    }

    actions {
        main: Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
        }
        contextualActions: [
            Kirigami.Action {
                text: rest.isLoggedIn ? "Logout" : "Login"
                iconName: "im-user"
                onTriggered: {
                      if (rest.isLoggedIn) {
                        settingsPage.logout();
                      } else
                        rest.authorize();

                }
            },

            Kirigami.Action {
                text: "Sort"
                iconName: "dialog-filters"
                onTriggered: changeSortOverlay.open()
            },
            Kirigami.Action {
                text: "Info"
                iconName: "help-about"
                onTriggered: subInfoOverlay.open()
                visible: isSubreddit
            },
            Kirigami.Action {
                id: favAction
                iconName: "favorite"
                checkable: true
                text: checked ? qsTr("Unfavorite") : qsTr("Favorite")
                onCheckedChanged: settingsPage.setFav(url, checked)
                visible: isSubreddit

                Component.onCompleted:  updateFav();

                function updateFav() {
                    checked = settingsPage.isFav(url);
                }
            }
        ]
    }


    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing && !postsModel.loadingPosts)
            refresh(true);
    }

    SortChoiceOverlay {
        id: changeSortOverlay
    }

    SubInfoOverlay {
        id: subInfoOverlay
        data: info
    }


    Connections {
        target: settingsPage.settings

        function onChanged() {
            console.debug("Settings changed");
            favAction.updateFav()
        }
    }


    Kirigami.CardsListView {
        id: postsView

        model: ListModel {
            id: postsModel
            property string after
            property string before
            property bool loadingPosts
        }
        delegate: PostCard {}
        onContentYChanged: {
            if (atYEnd) {
                rest.loadPostsAfter(url, model)
            }
        }
    }

    function getPostData(index) {
        return postsView.model.get(index);
    }

    onInfoChanged: {
        console.debug(`Info changed: `+info);
        title = info ? info.title : url;
    }

    function getInfo() {
        if (url.length <= 1) {
            console.debug("Frontpage");
            info = {
                title: "Frontpage",
                url: url
            };
            return Promise.resolve(info);
        } else {
            let infoUrl = url;
            if (url.charAt(url.length - 1) == '/')
                infoUrl = infoUrl.substr(0, infoUrl.length - 1);
            return rest.getRedditJSON(`${infoUrl}/about`)
                .then(rawData => info = DataConv.convertSub(rawData.data))
                .catch(raw => console.log(`info error: ${JSON.stringify(raw)}`));
        }
    }

    function refresh(forceRefresh = false) {
        model.clear();

        postsModel.loadingPosts = true;
        refreshing = true;

        let fullUrl = url;
        if (!Common.endsWith(fullUrl, "/"))
            fullUrl += "/";

        fullUrl += sortUrl;

        const fetchInfo = () => {
            if (info && info.url !== url)
                info = null;
           if (!info)
                getInfo();
        }

        rest.loadPosts(fullUrl, postsModel, null, forceRefresh).then(() => {
            refreshing = postsModel.loadingPosts = false;
        }).then(fetchInfo, fetchInfo);
    }
}
