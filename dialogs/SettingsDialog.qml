import QtQuick 2.1
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.3

import "../utils/common.js" as Common
import "../common"

Dialog {
    property Settings settings: Settings {
        id: settings
        property var favorites: []
        property alias themeName: themeInput.currentText
        property alias preferExternalBrowser: preferExternalBrowserInput.checked
        property alias imagePreviewChoice: imagePreviewChoiceBox.currentIndex
        property string accessToken
        property var accessTokenExpiry

        onThemeNameChanged: changed();
        onPreferExternalBrowserChanged: changed();
        onImagePreviewChoiceChanged: changed();
        onChanged: console.debug("Settings changed")

        onAccessTokenChanged: console.debug(`Settings access token: ${accessToken}`);

        onAccessTokenExpiryChanged: console.debug(`Settings access token expires: ${accessTokenExpiry}`);


        signal changed()

    }
    property var imagePreviewChoiceName: imagePreviewModel.get(imagePreviewChoiceBox.currentIndex).name

    property real cacheTimeout: 60
    property bool hasInit: false
    property var rawThemes

    title: "Settings"

    id: dialog
    objectName: "settingsDialog"

    standardButtons: StandardButton.Ok

    onVisibilityChanged: console.debug(`Settings dialog visible: ${visible}`);

    function setFav(url, isFav) {
        const wasFav = settings.favorites.indexOf(url) !== -1;
        if (wasFav && !isFav)
            settings.favorites.remove(url);
        else if (isFav && !wasFav)
            settings.favorites.push(url);

        settings.changed();
        settings.sync();
    }

    function isFav(url) {
        return settings.favorites.indexOf(url) !== -1;
    }

    function loadThemes() {
        console.debug(`load themes`);
        const rawThemes = styleTools.getThemes();

        var themesModel  = rawThemes.filter(raw => !Common.isLowerCase(Common.charAt(raw, 0)));
        themeInput.model = themesModel
        const theme = styleTools.getTheme();
        console.debug(`current theme: ${theme}`);
        themeInput.currentIndex = themesModel.indexOf(theme);
        hasInit= true;
    }

    function logout() {
        rest.accessToken = rest.accessTokenExpiry = null;
        rest.isLoggedIn = false;
        root.reload();
    }

    Kirigami.FormLayout {
        anchors.fill: parent
        Layout.fillWidth: true

        Connections {
            target: dialog
            Component.onCompleted:  {
                console.debug(`Settings inited: accessToken = ${settings.accessToken}; ${settings.accessTokenExpiry}`)
                rest.accessToken = settings.accessToken;
                rest.accessTokenExpiry = settings.accessTokenExpiry;
            }
        }

        Connections {
            target: themeInput
            function onCurrentTextChanged() {
                if (dialog.visible && hasInit) {
                    console.debug(`set theme: ${target.currentText}`);
                    styleTools.setTheme(target.currentText);
                }
            }
        }


        Connections {
            target: openUrlButton
            function onClicked() {
                Common.openLink(urlField.text);
            }
        }

        CheckBox {
            id: preferExternalBrowserInput

            Kirigami.FormData.label: "Prefer external browser:"
        }

        ComboBox {
            Layout.minimumWidth: Kirigami.Units.gridUnit * 20
             id: imagePreviewChoiceBox
             model: ListModel {
                id: imagePreviewModel
                ListElement {
                    desc: "Maximum resolution"
                    name: "max"
                }
                ListElement {
                    desc: "Minimum resolution"
                    name: "min"
                }
                ListElement {
                    desc: "Dynamic"
                    name: "dynamic"
                }
             }

             textRole: "desc"
             currentIndex: 0

             property string currentName: model.get(currentIndex).name

             Kirigami.FormData.label: qsTr("Image preview size")
        }

        TextField {
            Kirigami.FormData.label: "URL: "
            id: urlField
        }

        Button {
            id: openUrlButton
            text: qsTr("Open")
        }

        ComboBox {
            Layout.fillWidth: true
            property var themeNamesMap: new Map()
            id: themeInput
            Kirigami.FormData.label: qsTr("Theme: ")
        }
    }
}
