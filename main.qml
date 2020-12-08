import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQml.Models 2.12
import QtQuick.Controls 2.0 as Controls

import org.kde.kirigami 2.13 as Kirigami
import "common.js" as Common
import "pages"
import "common"

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
                visible: !navDrawer.collapsed
                Layout.fillWidth: true
                onAccepted: subsView.search(text)
                onEditingFinished: console.log("Done")

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
    SettingsPage {
        id: settingsPage
    }

    function showSettings() {
        settingsPage.loadThemes();
        pageStack.push(settingsPage)
    }

    function openPage(page) {
        if (root.pageStack.currentItem.objectName === page.objectName)
            root.pageStack.pop();
        root.pageStack.push(page);
    }

    function isCurrentPage(page) {
        return page === pageStack.currentItem;
    }
}
