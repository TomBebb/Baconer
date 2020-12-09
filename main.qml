import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQml.Models 2.12
import QtQuick.Controls 2.15 as Controls

import org.kde.kirigami 2.13 as Kirigami
import "utils/common.js" as Common
import "pages"
import "common"
import "utils"

Kirigami.ApplicationWindow {
    property bool assumeMobile: height > width * 1.5
    id: root
    title: `Baconer - ${subsView.currentURL}`
    controlsVisible: true


    Rest {
        id: rest
    }


    globalDrawer: Kirigami.GlobalDrawer {
        title: "Baconer subreddits"
        id: navDrawer
        showContentWhenCollapsed: true



        header: RowLayout {
            Layout.fillWidth: true

            Kirigami.SearchField {
                id: subsSearch
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

    Connections {
        target:  subsSearch
        function onAccepted() {
            subsView.search(text)
        }

        function onEditingFinished() {
            console.debug("Search edit finished");
        }
    }

    PostsPage    { id: postsPage }
    SettingsPage {
        id: settingsPage
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
