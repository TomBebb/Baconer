import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import "../common.js" as Common
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
        Kirigami.Action {
            text: Common.formatNum(ups)
            iconName: "arrow-up"
        },
        Kirigami.Action {
            text: Common.formatNum(downs)
            iconName: "arrow-down"
        },
        Kirigami.Action {
            text: Common.formatNum(commentCount)
            iconName: "dialog-messages"
            onTriggered: openPostInfoPage();
        }

    ]

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        RowLayout {
            id: delegateLayout
            width: parent.width

            ColumnLayout {
                Text {
                    Layout.minimumWidth: 100
                    Layout.preferredWidth: parent.width * rowEachWidthMult
                     color: 'orange'
                    text: `<b>By</b> ${author}`
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

                    Layout.fillWidth: true
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

    function openPostInfoPage() {

        const data = postsPage.getPostData(index);

        Common.createComponent("pages/PostPage.qml", {postData: data})
            .then(page => root.openPage(page))
            .catch(err => console.error(err))
    }
}
