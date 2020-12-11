import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13

OverlaySheet {
    id: sheet
    property var selectedSortUrl: sort.checked.value
    property var sortModel: [
        { name: "Hot", value: "hot" },
        { name: "New", value: "new" },
        { name: "Rising", value: "rising" },
        { name: "Controversial", value: "controversial" },
        { name: "Top today", value: "top?t=day" },
        { name: "Top last week", value: "top?t=week" },
        { name: "Top last month", value: "top?t=month" },
        { name: "Top last year", value: "top?t=year" },
        { name: "Top all-time", value: "top?t=all" },
    ]
    header: Heading {
        text: "Change sort"
    }


    ListView {
        property int checkedIndex: 0
        property var checked: sheet.sortModel[checkedIndex]
        anchors.centerIn: parent

        id: sort
        model:sortModel
        delegate: RadioDelegate {
            text: modelData.name
            checked: index === 0
            onCheckedChanged: if (checked) sort.checkedIndex = index
            width: parent.width
        }
    }

}
