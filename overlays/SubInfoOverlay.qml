import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import "../utils/common.js" as Common
import "../common"

Kirigami.OverlaySheet {
    id: sheet
    property var data: null
    onDataChanged: {
        if (!data || !data.name || !data.title || !data.subscribers)
            return;
        header.text = `${data.url} - ${data.title}`;
        desc.text = data.fullDescription;
        subs.text = qsTr("%1 subscribers").arg(Common.formatNum(data.subscribers));
    }


    ColumnLayout {
        Layout.fillWidth: true
        Kirigami.Heading {
            id: header
            level:  1
        }

        Label {
            id: subs
        }

        Label {
            id: desc
        Layout.fillWidth: true
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            onLinkActivated: Common.openLink(url);
        }


    }
}