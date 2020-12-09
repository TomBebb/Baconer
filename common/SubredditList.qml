import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import QtQml.Models 2.15
import "../utils/common.js" as Common

ListView {
    Layout.fillWidth: true
    property var currentData
    property string currentURL: currentData ? `${currentData.url}` : "/"
    model: ListModel { id: subsModel }

    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? title: `${title} (${url})`
        subtitle: description
        visible: isVisible
    }

    section.property: "category"
    section.delegate: Kirigami.ListSectionHeader {
        text: section
    }

    Connections {
        Component.onCompleted: {
            subsView.currentIndex = 0;
            rest.loadSubs(subsModel).then(rawDatas => {
                refresh();
            });
        }

        function onCurrentItemChanged() {
            refresh();
        }
    }

    function refresh() {
        currentData = model.get(currentIndex);
        if (!currentData) {
            console.error(`no index ${currentIndex} in subs; got ${currentData}`);
        }
        postsPage.info = currentData
        postsPage.refresh();
    }

    function search(text) {
        text = text.trim();

        console.log(`Search for: ${text}`);
        for (let i = 0; i < subsModel.count; i++) {
            const entry = subsModel.get(i);

            entry.isVisible = (text.length === 0) || Common.searchValuesFor(entry, text, false);
            console.log(`Result for ${JSON.stringify(entry)} => ${entry.visible}`);
        }
    }
}
