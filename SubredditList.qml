import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami
import QtQml.Models 2.15
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
            root.title += ` - ${current.url}`;

        console.log(`Load posts from: ${current.url}`);
        postsModel.clear();
        Common.loadPosts(current.url, postsModel).then(() => console.log(`Loaded posts from: ${current.url}`));
    }
    function getCurrentData() {
        return model.get(currentIndex);
    }
    
    function getURL() {
        const data = getCurrentData();
        return data ? data.url : "";
    }
}
