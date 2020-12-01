import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami


ListView {
    model: ListModel {}
    delegate: Kirigami.BasicListItem {
        label: Common.isFrontpage(this) ? name: `${name} (${url})`
        subtitle: description
    }
    onCurrentItemChanged: function() {
        let currentData = model.get(currentIndex);

        root.title = "Baconer";
        if (!Common.isFrontpage(currentData))
            root.title += ` - ${currentData.url}`;

        Common.loadPosts(currentData.url, postsModel);
    }
}
