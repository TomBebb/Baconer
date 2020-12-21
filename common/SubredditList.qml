import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import QtQml.Models 2.12
import QtQuick.Controls 2.0 as Controls
import "../utils/common.js" as Common

ListView {
    property var currentData: model.get(currentIndex)
    property string currentURL: currentData ? `${currentData.url}` : "/"
    property bool awaitingSearchData: false
    property string lastURL
    property string searchText

    ListModel {
        id: searchModel
    }

    ListModel {
        id: subsModel
    }


    Layout.fillWidth: true

    header: Controls.ProgressBar {
        visible: awaitingSearchData
        indeterminate: true
        padding: 0
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
    }

    model: stringUtils.isNonEmptyString(searchText) ? searchModel : subsModel
    clip: true
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds

    delegate: Kirigami.BasicListItem {
        label: url == "/" ? title: `${title} (${url})`
        subtitle: description || ""
        visible: isVisible
        icon : itemIcon ? itemIcon.source: ""
    }

    section.property: "category"
    section.delegate: Kirigami.ListSectionHeader {
        text: section
    }

    Connections {
        Component.onCompleted: {
            lastURL = currentURL;
            refreshAll();
        }

        function onCurrentItemChanged() {
            console.debug(`Item changed: lastURL=${lastURL}; currentURL=${currentURL}`);
            if (currentURL != lastURL) {
                navDrawer.close();
                root.pageStack.clear();
                root.pageStack.push(postsPage);
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
        }).catch(err => console.error(`Error loading subs: ${err}`));
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

    onSearchTextChanged:  {
        if (!stringUtils.isNonEmptyString(searchText)) {
            awaitingSearchData = false;
            return;
        }


        awaitingSearchData = true;

        rest.searchSubs(searchText)
            .then(subSearchResults => {
                awaitingSearchData = false;

                searchModel.clear();
                for (const searchData of subSearchResults) {
                    searchData.isVisible = true;
                    searchModel.append(searchData);
                }


                for (let i = 0; i < subsModel.count; i++) {
                    const entry = subsModel.get(i);

                    if (entry.category !== "Subreddits" && Common.searchValuesFor(entry, searchText, false)) {
                        const searchData = Object.assign({}, entry);
                        searchData.category = "Search results";
                        searchModel.append(searchData);
                    }
                }
            })
            .catch(err => {
                awaitingSearchData = false;
                console.error(`Error searching subs: ${err}`);
            });

    }

    function search(text) {
        searchText = text.trim();
    }
}
