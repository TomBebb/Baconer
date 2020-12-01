import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.11 as Kirigami

Kirigami.AbstractCard {
    property var hasContent: (postContent != null && postContent.length > 0)
    property var rowEachWidthMult: 0.2
    property var showImagePreview: (previewImage.length > 0)
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
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    textFormat: TextEdit.MarkdownText
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
