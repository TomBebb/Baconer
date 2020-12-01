import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami
import "common.js" as Common

Kirigami.ApplicationWindow {
    id: root
    title: "Baconer"

    Component.onCompleted: {
        console.log("Loading subreddits");
        Common.loadSubs(subsView.model);
        console.log("Loaded subreddits");
        console.log("Loading posts");
        subsView.currentIndex = 0;

        Common.loadPosts("/", postsModel);
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

        SubredditList {
            id: subsView
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
                property var hasContent: (postContent != null && postContent.length > 0)
                property var rowEachWidthMult: 0.2
                property var showImagePreview: (previewImage != null)
                property var showThumbnail: (!showImagePreview && thumbnail != null && thumbnail.length > 0)

                contentItem: Item {
                    implicitWidth: delegateLayout.implicitWidth
                    implicitHeight: delegateLayout.implicitHeight


                    RowLayout {
                        id: delegateLayout
                        width: parent.width

                        ColumnLayout {
                            Kirigami.Heading {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                level: 2
                                text: postTitle
                            }

                            Kirigami.Separator {
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                width: parent.width

                                Text {
                                    Layout.minimumWidth: 100
                                    Layout.preferredWidth: parent.width * rowEachWidthMult
                                    color: 'orange'
                                    text: `<b>By</b> ${author}`
                                }
                                Text {
                                    Layout.minimumWidth: 100
                                    Layout.preferredWidth: parent.width * rowEachWidthMult
                                    Layout.alignment: Layout.Center
                                    horizontalAlignment: Text.AlignHCenter
                                    color: 'blue'
                                    text: `<b>Comments:</b> ${commentCount}`
                                }

                                Text {
                                    Layout.minimumWidth: 100
                                    Layout.preferredWidth: parent.width * rowEachWidthMult
                                    Layout.alignment: Layout.Right
                                    horizontalAlignment: Text.AlignRight
                                    color: 'green'
                                    text: `<b>${score}</b>`
                                }
                            }

                            Controls.Label {
                                width: parent.width
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: postContent
                                visible: hasContent
                            }
                            Image {
                                source: previewImage
                                visible: showImagePreview
                                sourceSize.width: parent.width - 8
                                fillMode: Image.PreserveAspectFit
                                width: parent.width - 8
                            }
                        }
                        Image {
                            Layout.alignment: Layout.Right
                            source: thumbnail
                            visible: showThumbnail
                        }
                    }
                }
            }
        }
    }
    pageStack.initialPage: postsPage
}
