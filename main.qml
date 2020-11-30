import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common

Kirigami.ApplicationWindow {
    id: root
    title: "Baconer"

    Component.onCompleted: {
        Common.loadSubs(subsModel);
        subsView.currentIndex = 0;
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Baconer subreddits"
        id: navDrawer
        header: RowLayout {
            Layout.fillWidth: true
            Kirigami.SearchField {
                visible: !navDrawer.collapsed
                Layout.fillWidth: true
            }
        }

        ListView {
            id: subsView
            model: ListModel {
                id: subsModel
            }
            delegate: Kirigami.BasicListItem {
                label: Common.isFrontpage(this) ? name: `${name} (${url})`
                subtitle: description
            }
            onCurrentItemChanged: function() {
                let currentData = model.get(currentIndex);

                root.title = "Baconer";
                if (!Common.isFrontpage(currentData))
                    root.title += ` - ${currentData.url}`;

                Common.loadPosts(currentData.url, postsModel);
            }
        }
    }
    Kirigami.ScrollablePage {
        id: postsPage
        title: "Posts"
        Kirigami.CardsListView {
            id: postsView
            model: ListModel {
                id: postsModel
            }
            delegate: Kirigami.AbstractCard {
                contentItem: Item {

                    implicitWidth: delegateLayout.implicitWidth
                    implicitHeight: delegateLayout.implicitHeight
                    GridLayout {
                        id: delegateLayout

                        anchors {
                            left: parent.left
                            top: parent.top
                            right: parent.right
                        }
                        rowSpacing: Kirigami.Units.smallSpacing
                        columnSpacing: Kirigami.Units.smallSpacing

                        columns: 2
                        ColumnLayout {
                            Kirigami.Heading {
                                level: 2
                                text: postTitle
                            }
                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }
                            Controls.Label {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: postContent
                            }
                        }
                    }
                }
            }
        }
    }
    pageStack.initialPage: postsPage
}
