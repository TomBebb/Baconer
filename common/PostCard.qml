import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import Ionicon 1.0
import "/common.js" as Common
import "../actions"

Kirigami.Card {
    readonly property int maxPostPreviewLength: 255
    readonly property bool hasContent: Common.isNonEmptyString(postContent)
    readonly property real rowEachWidthMult: 0.2
    readonly property bool showImagePreview: (previewImage.length > 0)
    readonly property bool showThumbnail: (!showImagePreview && Common.isNonEmptyString(thumbnail))

    banner {
        title: postTitle
    }

    actions: [
        IconAction {
            text: "Upvote"
            iconName: "arrow-up-a"
        },
        IconAction {
            text: "Downvote"
            iconName: "arrow-down-a"
        },
        IconAction {
            text: "View comments"
            iconName: "chatbubbles"
            onTriggered: openPostInfoPage()
        }

    ]

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        RowLayout {
            id: delegateLayout
            width: parent.width

            ColumnLayout {
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
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: TextEdit.MarkdownText
                    text: postContent.length > maxPostPreviewLength ? postContent.substr(0, maxPostPreviewLength) + "..." : postContent
                    visible: hasContent

                    onLinkActivated: {
                        Common.openLink(link);
                    }

                }

                Image {
                    property var aspectRatio: imageHeight / imageWidth
                    source: previewImage
                    visible: showImagePreview
                    fillMode: Image.PreserveAspectFit

                    sourceSize.width: imageWidth
                    sourceSize.height: imageHeight

                    Layout.preferredWidth: parent.width - 8
                    Layout.preferredHeight: width * aspectRatio

                }
            }
            Image {
                Layout.alignment: Layout.Right
                fillMode: Image.PreserveAspectFit
                source: thumbnail
                visible: showThumbnail
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onDoubleClicked: {
            console.log("clicked "+index);
            openPostInfoPage();

        }
    }

    function openPostInfoPage() {

        const data = postsPage.getPostData(index);

        Common.createComponent("pages/PostPage.qml", {data: data})
            .then(page => root.pageStack.push(page))
            .catch(err => console.error(err))
    }
}
