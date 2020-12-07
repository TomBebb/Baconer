import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import QtQml.Models 2.15
import "/common.js" as Common

ListView {

    Layout.fillWidth: true
    property var currentData
    property string currentURL: currentData ? `${currentData.url}` : "/"
    model: ListModel { id: subsModel }
    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? title: `${title} (${url})`
        subtitle: description
    }

    Component.onCompleted: {
        subsView.currentIndex = 0;
        console.debug("loading subs");
        rest.loadSubs(subsModel).then(rawDatas => {
            console.debug(`subs: ${subsModel.count}`);
            refresh();
        });
    }

    onCurrentItemChanged: () => refresh();

    function refresh() {
        currentData = model.get(currentIndex);
        if (!currentData) {
            console.error(`no index ${currentIndex} in subs; got ${currentData}`);
        }
        postsPage.info = currentData
        postsPage.refresh();
    }
}
