import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13 as Kirigami
import "../utils/common.js" as Common

Kirigami.Card {
    id: postCard
    readonly property string subredditURL: `/r/${subreddit}`
    readonly property int maxPostPreviewLength: 255
    readonly property bool hasContent: Common.isNonEmptyString(postContent)
    readonly property real rowEachWidthMult: 0.2
    readonly property bool showImagePreview: previewImage.isValid
    readonly property bool showThumbnail: (!showImagePreview && Common.isNonEmptyString(thumbnail))

    banner {
        title: postTitle
    }

    actions: [
        Kirigami.Action {
            text: Common.formatNum(ups)
            iconName: "arrow-up"

            onTriggered: {
                rest.vote(fullName, 1);
            }

        },
        Kirigami.Action {
            text: Common.formatNum(downs)
            iconName: "arrow-down"

            onTriggered: {
                rest.vote(fullName, -1);
            }
        },
        Kirigami.Action {
            text: Common.formatNum(commentCount)
            iconName: "dialog-messages"
            onTriggered: openPostInfoPage();
        },

        Kirigami.Action {
            iconName: "favorite"
            checkable: true
            checked: saved
            text: checked ? qsTr("Unsave") : qsTr("Save")
            onCheckedChanged: rest.setSaved(fullName, checked)
            visible: rest.isLoggedIn
        }

    ]

    contentItem: Item {
        id: item
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight


        ColumnLayout {
            id: delegateLayout
            Controls.Label {
                property bool isActiveSub: subredditURL === root.pageStack.currentItem.url
                Layout.fillWidth: true
                text: qsTr("posted by %1 %2 ago" + (isActiveSub ? "%3" : " in %3"))
                    .arg(`[${author}](http://reddit.com/u/${author})`)
                    .arg(Common.timeSince(date))
                    .arg(isActiveSub ? "": `[/r/${subreddit}](http://reddit.com/r/${subreddit})`)
                textFormat: TextEdit.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                LinkHandlerConnection {}
            }

            Controls.Label {
                Layout.fillWidth: true
                Layout.preferredWidth: item.width
                textFormat: TextEdit.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: postContent.length > maxPostPreviewLength ? postContent.substr(0, maxPostPreviewLength) + "..." : postContent
                visible: hasContent

                LinkHandlerConnection {}
            }

            Controls.Label {
                Layout.fillWidth: true
                text: `[Open URL](${url})`
                textFormat: TextEdit.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: url.length > 0
                LinkHandlerConnection {}
            }

            Image {
                property var rawData: previewImage
                property var aspectRatio: rawData.height / rawData.width
                source: rawData.url ? rawData.url : ""
                visible: showImagePreview
                sourceSize.width: rawData.width
                sourceSize.height: rawData.height

                fillMode: Image.PreserveAspectFit

                Layout.preferredWidth: postCard.width - 20
                Layout.preferredHeight: width * aspectRatio
            }
        }
    }

    function openPostInfoPage() {

        const data = postsPage.getPostData(index);

        Common.createComponent("/pages/PostPage.qml", {postData: data})
            .then(page => root.openPage(page))
            .catch(err => console.error(`Error loading post: ${err}`));
    }
}
