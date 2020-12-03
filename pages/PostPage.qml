import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Layouts 1.2
import "/common.js" as Common
import "../actions"

Kirigami.ScrollablePage {
    property var data
    readonly property bool hasContent: Common.isNonEmptyString(data.postContent)
    title: data.postTitle
    actions {
        main: BackAction {}
    }


    Component.onCompleted: {
        contentLabel.text = data.postContent;
    }

    ColumnLayout {
        Controls.Label {
            id: contentLabel
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: TextEdit.MarkdownText
            visible: hasContent

            onLinkActivated: {
                Common.openLink(link);
            }
        }
    }
}
