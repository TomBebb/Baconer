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
        spacing: Units.smallSpacing
        Controls.Label {
            id: contentLabel
            Layout.fillWidth: true
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            visible: !refreshing
            text: postData.postContent

            LinkHandlerConnection {

            }
        }

        ListView {
            id: commentsList
            Layout.fillWidth: true


            delegate: Controls.Label {
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: body
                textFormat: TextEdit.MarkdownText
                onLinkActivated: Common.openLink(link)
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
