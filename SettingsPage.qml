import QtQuick 2.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common

Kirigami.ScrollablePage {
    title: "Settings"
    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                Kirigami.FormData.label: "Prefer external browser:"
            }
            ComboBox {
                editable: false
                model: SortModel {}
                Kirigami.FormData.label: "Default post sort:"
            }
        }
    }
}
