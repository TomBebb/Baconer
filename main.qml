import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common

Kirigami.ApplicationWindow {
    id: root
    title: "Baconer"

    Component.onCompleted: {
        Common.loadSubs(subsView.model);
        subsView.currentIndex = 0;

        Common.loadPosts("/", postsModel);
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Baconer subreddits"
        id: navDrawer
        header: RowLayout {
            Layout.fillWidth: true

            Kirigami.SearchField {
                visible: !navDrawer.collapsed
                Layout.fillWidth: true
            }
        }

        SubredditList {
            id: subsView
        }
    }
    Kirigami.ScrollablePage {
        id: postsPage
        title: "Posts"
        Kirigami.CardsListView {
            id: postsView
            model: ListModel {
                property string after
                property string before
                property bool loadingPosts
                id: postsModel
            }
            delegate: PostCard {}
            onContentYChanged: {
            
                if (atYEnd) {
                    const url = subsView.getURL();
                    Common.loadPostsAfter(url, postsModel)
                }
            }
        }
    }
    pageStack.initialPage: postsPage
}
