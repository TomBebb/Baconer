import QtQuick 2.1
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import Qt.labs.settings 1.0
import "../utils/common.js" as Common
import "../common"

Kirigami.ScrollablePage {
    property Settings settings: settings
    property var imagePreviewChoiceName: imagePreviewModel.get(imagePreviewChoiceBox.currentIndex).name
    property real cacheTimeout: 60
    title: "Settings"
    property var rawThemes
    id: page
    objectName: "settingsPage"

    function setFav(url, isFav) {
        const wasFav = isFav(url);
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
        const rawThemes = styleTools.getThemes();

        var themesModel  = rawThemes.filter(raw => !Common.isLowerCase(Common.charAt(raw, 0)));
        themeInput.model = themesModel
        const theme = styleTools.getTheme();
        themeInput.currentIndex = themesModel.indexOf(theme);
    }

    function logout() {
        settings.accessToken = settings.accessTokenExpiry = null;
        root.reload();
    }

    Settings {
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
    ColumnLayout {
        Kirigami.FormLayout {
            Layout.fillWidth: true

            CheckBox {
                id: preferExternalBrowserInput

                Kirigami.FormData.label: "Prefer external browser:"
            }

            ComboBox {
                 Layout.preferredWidth: 200
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

                 Kirigami.FormData.label: "Image preview size"
            }

            TextField {
                Kirigami.FormData.label: "Url: "
                id: urlField
            }

            Button {
                id: openUrlButton
                text: "Open"
            }

            ComboBox {
                property var themeNamesMap: new Map()
                id: themeInput
                Kirigami.FormData.label: "Theme: "
            }
            Button {
                id: doneButton
                text: "Done"
            }
        }
    }

    Connections {
        Component.onCompleted:  {
            console.debug(`Settings inited: accessToken = ${settings.accessToken}; ${settings.accessTokenExpiry}`)
            rest.accessToken = settings.accessToken;
            rest.accessTokenExpiry = settings.accessTokenExpiry;
        }
    }

    Connections {
        target: themeInput
        function onCurrentTextChanged() {
            if (root.isCurrentPage(page))
                styleTools.setTheme(target.currentText);
        }
    }


    Connections {
        target: openUrlButton
        function onClicked() {
            Common.openLink(urlField.text);
        }
    }

    Connections {
        target: doneButton
        function onClicked() {
            console.debug("Done pressed: "+page);
            root.closePage(page);
        }
    }
}
