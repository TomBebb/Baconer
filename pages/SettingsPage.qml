import QtQuick 2.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.11 as Kirigami
import Qt.labs.settings 1.0
import "/common.js" as Common
import "../common"
import "../actions"

Kirigami.ScrollablePage {
    title: "Settings"
    actions {
        main: BackAction {}
    }


    Settings {
        id: settings
        property alias preferExternalBrowser: preferExternalBrowserInput.checked
        property alias defaultSort: defaultPostSortInput.currentIndex
    }
    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                id: preferExternalBrowserInput
                Kirigami.FormData.label: "Prefer external browser:"
            }
            ComboBox {
                id: defaultPostSortInput
                editable: false
                model: SortModel {}
                Kirigami.FormData.label: "Default post sort:"
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
    property var settings: settings
}
