import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import "../common.js" as Common
import "../actions"

Kirigami.Page {
    property var postData
    property var commentsData
    readonly property bool hasContent: Common.isNonEmptyString(postData.postContent)

    objectName: "postPage"

    actions {
        main: Kirigami.Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
            enabled: !commentsModel.loadingComments
        }
    }

    Component.onCompleted: refresh();

    title: postData.postTitle
    ColumnLayout {
        anchors.fill: parent
        Controls.Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: TextEdit.MarkdownText
            visible: hasContent
            text: postData.postContent

            onLinkActivated: {
                Common.openLink(link);
            }
        }

        ListView {
            id: commentsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            delegate: Kirigami.BasicListItem {
               text: body
               subtitle: author
            }
            model: ListModel {
                property bool loadingComments: false
                id: commentsModel
            }
        }
    }

    function refresh(forceRefresh = false) {
        rest.loadComments(postData, commentsModel, forceRefresh);
    }
}
