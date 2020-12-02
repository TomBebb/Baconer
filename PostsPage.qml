import QtQuick 2.0
import org.kde.kirigami 2.11 as Kirigami

Kirigami.ScrollablePage {
    property var model: postsView.model

    title: `${getData().title} (${getData().url})`
    Kirigami.CardsListView {
        id: postsView
        model: ListModel {
            property string after
            property string before
            property bool loadingPosts
        }
        delegate: PostCard {}
        onContentYChanged: {

            if (atYEnd) {
                const url = subsView.getURL();
                Common.loadPostsAfter(url, model)
            }
        }
    }

    function getData() {
        return subsView.getCurrentData();
    }
}
