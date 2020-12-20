import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13
import "../utils/common.js" as Common
import "../utils/dataConverters.js" as DataConv
import "../common"
import "../overlays"

ScrollablePage {
    property ListModel model: postsModel
    property string url: subsView.currentURL
    property string sortUrl: changeSortOverlay.selectedSortUrl
    property bool isSubreddit: url.indexOf("/r/") === 0
    property var info: null
    objectName: "postsPage"
    id: postsPage

    title: url

    Layout.fillWidth: true

    onSortUrlChanged: refresh()

    Component.onCompleted: {
        refresh();
    }

    Connections {
        target: flickable
        function onContentYChanged() {
            if (flickable.atYEnd)
                loadPostsAfter();
        }
    }

    actions {
        main: Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
        }
        contextualActions: [
            Action {
                text: rest.isLoggedIn ? "Logout" : "Login"
                iconName: "im-user"
                onTriggered: {
                      if (rest.isLoggedIn) {
                        settingsDialog.logout();
                      } else
                        rest.authorize();

                }
            },

            Action {
                text: "Sort"
                iconName: "dialog-filters"
                onTriggered: changeSortOverlay.open()
            },
            Action {
                text: "Info"
                iconName: "help-about"
                onTriggered: subInfoOverlay.open()
                visible: isSubreddit
            },
            Action {
                text: "Setting"
                iconName: "gtk-preferences"
                onTriggered: root.showSettings()
            },
            Action {
                id: favAction
                iconName: "favorite"
                checkable: true
                text: checked ? qsTr("Unfavorite") : qsTr("Favorite")
                onCheckedChanged: settingsDialog.setFav(url, checked)
                visible: isSubreddit

                Component.onCompleted:  updateFav();

                function updateFav() {
                    checked = settingsDialog.isFav(url);
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
        target: settingsDialog.settings

        function onChanged() {
            console.debug("Settings changed");
            favAction.updateFav()
        }
    }

    RowLayout {
        id: layout
        Layout.fillWidth: true
        Layout.fillHeight: true

        CardsListView {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.maximumWidth: root.pageStack.defaultColumnWidth
            Layout.fillWidth: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            spacing: Units.gridUnit * 0.5
            implicitHeight: childrenRect.height

            model: ListModel {
                id: postsModel
                property string after
                property string before
                property bool loadingPosts
            }
            delegate: PostCard {
            }
        }
    }

    function getPostData(index) {
        return postsModel.get(index);
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
            return rest.loadSubInfo(url)
                .then(newInfo => info = newInfo)
                .catch(err => console.error(`Error getting info: ${err}`));
        }
    }

    function refresh(forceRefresh = false) {

        postsModel.clear();

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
            console.debug("Done loading (posts page)");
            refreshing = postsModel.loadingPosts = false;
        }).then(fetchInfo, fetchInfo);
    }

    function loadPostsAfter() {
        console.debug("loadPostsAfter");
        if (postsModel.loadingPosts)
            return;
        let fullUrl = url;
        if (!Common.endsWith(fullUrl, "/"))
            fullUrl += "/";

        fullUrl += sortUrl;


        rest.loadPostsAfter(fullUrl, postsModel, false).catch(err => console.error(`Error loading next posts: ${err}`));

    }
}
