import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common


ListView {
    id: subsList
    model: ListModel { id: subsModel }
    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? name: `${name} (${url})`
        subtitle: description
    }
    onCurrentItemChanged: function() {
        const current = getCurrentData();
        root.title = "Baconer";
        if (!Common.isFrontpage(current))
            root.title += ` - ${currentData.url}`;

        Common.loadPosts(current.url, postsModel)
    }
    function getCurrentData() {
        return model.get(currentIndex);
    }
    
    function getURL() {
        return getCurrentData().url;
    }
}
