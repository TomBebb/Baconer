import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Layouts 1.2
import "../common.js" as Common
import "../actions"

Kirigami.Page {
    property var data
    readonly property bool hasContent: Common.isNonEmptyString(data.postContent)



    Component.onCompleted: refresh();

    title: data.postTitle
    ColumnLayout {
        Controls.Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: TextEdit.MarkdownText
            visible: hasContent
            text: data.postContent

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
        }
    }

    function refresh(forceRefresh = false) {
        console.debug(`Refresh comments: force=${forceRefresh}`);
        rest.loadComments(postData, commentsModel, forceRefresh);
    }
}
