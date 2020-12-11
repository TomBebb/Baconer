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

    ColumnLayout {
        anchors.fill: parent

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            spacing: Kirigami.Units.gridUnit * 0.5

            model: ListModel {
                id: scopesModel
            }
            delegate: CheckBox {
                text: name
                checked: true
                hoverEnabled: true

                ToolTip {
                    visible: hovered
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
        }
    }


    onScopesDataChanged:  {
        if (!scopesData)
            return;

        scopesModel.clear();
        for (const scopeData of scopesData)
            scopesModel.append(scopeData);
        console.debug(`scope #1: ${JSON.stringify(scopesData[0])}`);
    }

    Component.onCompleted: {
        rest.getScopes()
            .then(scopes => scopesData = scopes)
            .catch(err => console.error(`error fetching scopes: ${err}`));
    }
}
