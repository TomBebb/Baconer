import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQml.Models 2.15
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common
import Ionicon 1.0

Kirigami.ApplicationWindow {
    id: root
    title: "Baconer"
    controlsVisible: true
    Component.onCompleted: {
        Common.loadSubs(subsView.model);
        subsView.currentIndex = 0;

        Common.loadPosts(subsView.getURL(), postsModel);
    }

    IoniconLoader {}

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Baconer subreddits"
        id: navDrawer
        showContentWhenCollapsed: true

        header: RowLayout {
            Layout.fillWidth: true

            Kirigami.SearchField {
                visible: !navDrawer.collapsed
                Layout.fillWidth: true
            }
        }

        SubredditList {
            id: subsView
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    pageStack.initialPage: postsPage

    PostsPage    { id: postsPage }
}
