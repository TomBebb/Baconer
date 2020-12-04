import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "/common.js" as Common
import "../common"
import "../actions"

Kirigami.ScrollablePage {
    property ListModel model: postsView.model
    property string url: subsView.currentURL
    property string sortUrl: "hot"
    property var info: null

    Component.onCompleted: {
        reload();
    }
    actions {
        main: IconAction {
            text: "Refresh"
            iconName: "refresh"
            onTriggered: reload()
        }
        left: IconAction {
            text: "Settings"
            iconName: "settings"
            onTriggered: root.showSettings()
        }
        contextualActions: [
            Kirigami.Action {
                displayComponent:  RowLayout {
                    Controls.Label {
                        text: "Sort:"
                    }

                    Controls.ComboBox {
                        id: sort
                        model: [
                            { name: "Hot", value: "hot" },
                            { name: "New", value: "new" },
                            { name: "Rising", value: "rising" },
                            { name: "Controversial", value: "controversial" },
                            { name: "Top today", value: "top?t=day" },
                            { name: "Top last week", value: "top?t=week" },
                            { name: "Top last month", value: "top?t=month" },
                            { name: "Top last year", value: "top?t=year" },
                            { name: "Top all-time", value: "top?t=all" },
                        ]
                        textRole: "name"
                        valueRole: "value"
                        currentIndex: 0

                        onActivated: {
                            sortUrl = currentValue;
                            reload();
                        }
                    }
                }

                displayHint: Kirigami.DisplayHints.KeepVisible
            }

        ]
    }

    title: url
    Kirigami.CardsListView {
        id: postsView
        model: ListModel {
            property string after
            property string before
            property bool loadingPosts
        }
        delegate: PostCard {}
        onContentYChanged: {

            if (atYEnd) {
                Common.loadPostsAfter(url, model)
            }
        }
    }

    function getPostData(index) {
        return postsView.model.get(index);
    }

    onInfoChanged: {
        title = info ? url : info.title;
    }

    function reload() {
        model.clear();
        console.log(`Reload info=${Common.toString(info)}; url=${url}; sorturl=${sortUrl}`);
        Common.loadPosts(url + sortUrl, model);
        if (info && info.url !== url)
            info = null;

        if (info)
            return;
        if (url.length <= 1) {
            info = {
                title: "Frontpage"
            };
        } else {
            let infoUrl = url;
            if (url.charAt(url.length - 1) == '/')
                infoUrl = infoUrl.substr(0, infoUrl.length - 1);
            Common.getRedditJSON(`${infoUrl}/about`)
                .then(rawData => info = rawData.data)
                .catch(raw => console.log(`info error: ${Common.toString(raw)}`));
        }
    }
}
