import QtQuick 2.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import Qt.labs.settings 1.0
import "../common.js" as Common
import "../common"
import "../actions"

Kirigami.ScrollablePage {
    property Settings settings: settings
    property var rawThemes
    title: "Settings"
    objectName: "settingsPage"

    function loadThemes() {
        const rawThemes = styleTools.getThemes();

        var themesModel = rawThemes.filter(raw => !Common.isLowerCase(Common.charAt(raw, 0)));
        themeInput.model = themesModel
        const theme = styleTools.getTheme();
        themeInput.currentIndex = themesModel.indexOf(theme);
    }

    Settings {
        id: settings
        property alias themeName: themeInput.currentText
        property alias preferExternalBrowser: preferExternalBrowserInput.checked
    }
    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                id: preferExternalBrowserInput

                Kirigami.FormData.label: "Prefer external browser:"
            }

            ComboBox {
                property var themeNamesMap: new Map()
                id: themeInput
                Kirigami.FormData.label: "Theme: "
                onCurrentTextChanged: if(root.isCurrentPage(settingsPage)) styleTools.setTheme(currentText)
            }
            Button {
                text: "Done"
                onClicked: root.pageStack.pop()
            }
        }
    }
}
