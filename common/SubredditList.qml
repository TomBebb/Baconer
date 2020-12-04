import QtQuick 2.1
import org.kde.kirigami 2.13 as Kirigami
import QtQml.Models 2.15
import "/common.js" as Common

ListView {
    property var currentData
    property string currentURL: currentData ? `${currentData.url}` : "/"
    model: ListModel { id: subsModel }
    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? title: `${title} (${url})`
        subtitle: description
    }

    onCurrentItemChanged: () => reload();

    function reload() {
        currentData = model.get(currentIndex);
        if (!currentData) {
            console.error(`no index ${currentIndex} in subs; got ${currentData}`);
        }
        postsPage.info = currentData
        postsPage.reload();
    }
}
