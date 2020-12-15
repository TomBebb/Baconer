import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQml.Models 2.12
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.13
import "utils/common.js" as Common
import "pages"
import "common"
import "utils"

ApplicationWindow {
    property bool assumeMobile: height > width * 1.5
    id: root
    title: `Baconer - ${pageStack.currentItem.title}`
    property Rest rest: rest

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

    Connections {
        target: subsSearch
        function onAccepted() {
            subsView.search(target.text)
        }
    }

    PostsPage    {
        id: postsPage
    }
    SettingsPage {
        id: settingsPage
    }

    function reload() {
        pageStack.pop(postsPage);
        subsView.refreshAll(false);
        postsPage.refresh(true);
    }

    function showSettings() {
        settingsPage.loadThemes();
        pageStack.push(settingsPage)
    }

    function openPage(page) {
        closePage(page);
        pageStack.push(page);
    }

    function closePage(page) {
        pageStack.removePage(page);
    }

    function isCurrentPage(page) {
        return page === pageStack.currentItem;
    }

    Component.onCompleted: pageStack.push(postsPage)
}
