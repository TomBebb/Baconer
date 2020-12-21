import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQml.Models 2.12
import org.kde.kirigami 2.13
import "pages"
import "common"
import "dialogs"
import "utils"

ApplicationWindow {
    property bool assumeMobile: height > width * 1.5
    property Page currentPage: root.pageStack.currentItem
    property int numGifs: 0
    id: root
    title: `Baconer - ${currentPage.title}`
    property Rest rest: rest

    pageStack.interactive: true
    pageStack.defaultColumnWidth: Units.gridUnit * 40


    Rest {
        id: rest
    }

    globalDrawer: GlobalDrawer {
        title:  subsView.searchText ? qsTr("Search results") : (rest.isLoggedIn ? qsTr("My subscriptions") : qsTr("Subreddits"))
        id: navDrawer
        showContentWhenCollapsed: true

        header: RowLayout {
            Layout.fillWidth: true

            SearchField {
                id: subsSearch
                visible: !navDrawer.collapsed
                Layout.fillWidth: true

            }
        }

        SubredditList {
            id: subsView
            Layout.fillHeight: true
        }
    }

    Shortcut {
        sequence: "Ctrl+K"
        onActivated: {
            navDrawer.visible = true;
            subsSearch.focus = true;
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: navDrawer.visible = !navDrawer.visible
    }

    Connections {
        target: subsSearch
        function onAccepted() {
            subsView.search(target.text)
        }
    }

    PostsPage    {
        id: postsPage
    }


    SettingsDialog {
        id: settingsDialog
    }

    Page {
        id: vidDemo
        title:  "Video demo"
        Layout.fillWidth: true
        VideoPlayer {
            anchors.fill: parent

            source: "https://v.redd.it/zapj141xgc661/DASH_240.mp4"
        }
    }

    function reload() {
        pageStack.pop(postsPage);
        subsView.refreshAll(false);
        postsPage.refresh(true);
    }

    function showSettings() {
        settingsDialog.open();
        settingsDialog.loadThemes();
    }

    function openPage(page) {
        closePage(page);
        pageStack.push(page);
    }

    function closePage(page) {
        pageStack.removePage(page);
    }

    function isCurrentPage(page) {
        return page === currentPage;
    }

    Component.onCompleted: pageStack.push(postsPage)
}
