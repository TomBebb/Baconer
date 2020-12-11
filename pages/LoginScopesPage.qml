import QtQuick 2.15
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import "../utils/common.js" as Common
import "../common"

Kirigami.Page {
    id: page
    objectName: "ScopePage"
    title: "Login Scope Selection"

    property var scopesData
    property bool globalChecked: true
    onGlobalCheckedChanged: Common.setAll(scopesView, "checked", globalChecked)

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.alignment: Qt.AlignTop
            Button {
                Layout.alignment: Qt.AlignLeft
                text: "Select all"
                onPressed: globalChecked = true
            }
            Button {
                Layout.alignment: Qt.AlignRight
                text: "Select none"
                onPressed: globalChecked = false
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            spacing: Kirigami.Units.gridUnit * 0.5
            id: scopesView

            model: ListModel {
                id: scopesModel
            }
            delegate: Column {
                property int index: scopeIndex
                CheckBox {
                    text: name
                    checked: globalChecked
                    font.bold: true
                    onCheckedChanged: scopesData[index].checked = checked
                }
                Label {
                    text: description
                }
            }

            ScrollBar.vertical: ScrollBar {}
        }


        Button {

            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            Layout.minimumWidth: 200
            text: "Done"
            onPressed: {

                let scopes = [];
                console.debug("Done picking scopes: ");
                for (const scopeData of scopesData) {
                    if (!scopeData.checked)
                        continue;
                    console.debug(`Scope: ${scopeData.id}`);

                    scopes.push(scopeData.id);
                }
                rest.authorize(scopes);

                root.closePage(page);
            }
        }
    }


    onScopesDataChanged:  {
        if (!scopesData)
            return;

        scopesModel.clear();

        let i = 0;
        for (const scopeData of scopesData) {
            scopeData.scopeIndex = i++;
            scopesModel.append(scopeData);
        }
        console.debug(`scope #1: ${JSON.stringify(scopesData[0])}`);
    }

    Component.onCompleted: {
        rest.getScopes()
            .then(scopes => scopesData = scopes)
            .catch(err => console.error(`error fetching scopes: ${err}`));
    }
}
