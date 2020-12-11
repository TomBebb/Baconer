import QtQuick 2.15
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import "../utils/common.js" as Common
import "../common"

Kirigami.ScrollablePage {
    id: page
    property var postData
    property var commentsData
    readonly property bool hasContent: Common.isNonEmptyString(postData.postContent)
    property bool loadingComments: false


    objectName: "postPage"

    actions {
        main: Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
            enabled: !commentsModel.loadingComments
        }
    }

    Shortcut {
        sequences: [StandardKey.Refresh, "Ctrl+R"]
        onActivated: refresh(true)
    }

    Component.onCompleted: refresh();


    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing && !loadingComments)
            refresh(true);
    }

    title: postData.postTitle
    ColumnLayout {
        width: page.width
        id: layout
        visible: !refreshing
        Controls.Label {
            id: contentLabel
            Layout.preferredWidth: layout.width
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: postData.postContent

            LinkHandlerConnection {

            }
        }

        ListView {
            id: commentsList
            Layout.preferredWidth: layout.width
            Layout.preferredHeight: root.height

            delegate: Kirigami.AbstractListItem {
                id: commentItem

                Controls.Label {
                    id: commentText
                    color:  commentItem.textColor
                    text: Common.decodeHtml(body)
                    textFormat: TextEdit.MarkdownText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    onLinkActivated: Common.openLink(url);
                }
            }

            model: ListModel {
                property bool loadingComments: false
                id: commentsModel
            }
        }
    }

    function refresh(forceRefresh = false) {
        loadingComments = true;
        refreshing = true;
        commentsModel.clear();
        rest.loadComments(postData, commentsModel, forceRefresh)
            .then(() => {
               loadingComments = refreshing = false;
            });
    }
}
