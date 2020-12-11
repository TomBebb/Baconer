import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import QtQml.Models 2.15
import "../utils/common.js" as Common

ListView {
    property var currentData: model.get(currentIndex)
    property string currentURL: currentData ? `${currentData.url}` : "/"
    property string lastURL
    Layout.fillWidth: true
    model: ListModel { id: subsModel }
    clip: true
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds

    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? title: `${title} (${url})`
        subtitle: description || ""
        visible: isVisible
        icon : itemIcon ? itemIcon.source: ""
    }

    section.property: "category"
    section.delegate: Kirigami.ListSectionHeader {
        text: section
    }

    Connections {
        target: settingsPage.settings
        function onChanged() {
            console.debug(`changed: currentItem=${currentItem}; index = ${currentIndex}; data = ${model.get(currentIndex).url}`);
            refreshAll(false)
        }
    }

    Connections {
        Component.onCompleted: {
            lastURL = currentURL;
            refreshAll();
        }

        function onCurrentItemChanged() {
            if (currentURL != lastURL) {
                root.pageStack.pop(root.pageStack.get(0));
                refreshSubInfo();
                lastURL = currentURL;
            }
        }
    }

    function refreshAll(refreshPosts) {
        const currentUrl = currentURL;

        rest.loadDrawerItems(subsModel).then(rawDatas => {

            let newUrlIndex = -1;
            for (let i = 0; i < model.count; i++) {
                const itemData = model.get(i);
                const url = itemData.url;
                if (url === currentUrl) {
                    newUrlIndex = i;
                    break;
                }
            }
            currentIndex = newUrlIndex;
            refreshSubInfo(refreshPosts);
        }).catch(err => console.error(`Error loading subs: ${JSON.stringify(err)}`));
    }

    function refreshPosts(forceRefresh) {
        return postsPage.refresh(forceRefresh)
    }

    function refreshSubInfo(shouldRefreshPosts = true) {
        postsPage.info = currentData

        if (shouldRefreshPosts)
            return refreshPosts();

        return Promise.resolve();
    }

    function search(text) {
        text = text.trim();

        for (let i = 0; i < subsModel.count; i++) {
            const entry = subsModel.get(i);

            entry.isVisible = (text.length === 0) || Common.searchValuesFor(entry, text, false);
        }
    }
}
