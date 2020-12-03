import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQml.Models 2.15
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import Ionicon 1.0
import "common.js" as Common
import "pages"
import "common"

Kirigami.ApplicationWindow {
    property bool assumeMobile: height > width * 1.5
    id: root
    title: `Baconer - ${subsView.currentURL}`
    controlsVisible: true


    Component.onCompleted: {
        subsView.currentIndex = 0;
        Common.loadSubs(subsView.model).then(() => {
            subsView.reload();
        });
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
    SettingsPage { id: settingsPage }


    function showSettings() {
        console.log(settingsPage.preferExternalBrowserInput);
        if (pageStack.currentPage !== settingsPage)
            pageStack.push(settingsPage)
    }
}
