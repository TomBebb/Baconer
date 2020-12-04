import QtQuick 2.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import Qt.labs.settings 1.0
import "/common.js" as Common
import "../common"
import "../actions"

Kirigami.ScrollablePage {
    property Settings settings: settings
    title: "Settings"
    actions {
        main: BackAction {}
    }


    Settings {
        id: settings
        property alias preferExternalBrowser: preferExternalBrowserInput.checked
    }
    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                id: preferExternalBrowserInput
                Kirigami.FormData.label: "Prefer external browser:"
            }
            TextField {
                id: url
                Kirigami.FormData.label: "URL to open:"
            }

            Button {
                text: "Open URL"
                onClicked: Common.openLink(url.text)
            }
        }
    }
}
