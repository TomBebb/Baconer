import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13
import "../utils/common.js" as Common

Card {
    id: postCard
    readonly property string subredditURL: `/r/${subreddit}`
    readonly property int maxPostPreviewLength: 255
    readonly property bool hasContent: Common.isNonEmptyString(postContent)
    readonly property real rowEachWidthMult: 0.2
    readonly property bool showImagePreview: previewImage.isValid && !showVideoPreview
    readonly property bool showVideoPreview: previewVideo.isValid
    readonly property bool showThumbnail: (!showImagePreview && Common.isNonEmptyString(thumbnail))
    readonly property bool isActiveSub: root.currentPage && root.currentPage.url != null && subredditURL === root.currentPage.url
    property int voteValue: 0

    banner {
        title: postTitle
        titleLevel: 4
        titleWrapMode: Text.WrapAtWordBoundaryOrAnywhere
        source: showImagePreview && previewImage.url ? previewImage.url : ""
    }
    actions: [
        Action {
            text: Common.formatScore(score + voteValue)
        },

        Action {
            iconName: "arrow-up"
            enabled: voteValue !== -1
            visible: rest.isLoggedIn
            tooltip: voteValue == 1 ? qsTr("Cancel upvote") : qsTr("Upvote")

            onTriggered: {
                voteValue = voteValue == 1 ? 0 : 1;
                rest.vote(fullName, voteValue);
            }

        },
        Action {
            iconName: "arrow-down"
            enabled: voteValue !== 1
            visible: rest.isLoggedIn
            tooltip: voteValue == -1 ? qsTr("Cancel downvote") : qsTr("Downvote")
            onTriggered: {
                voteValue = voteValue == -1 ? 0 : -1;
                rest.vote(fullName, voteValue);
            }
        },
        Action {
            text: Common.formatNum(commentCount)
            iconName: "dialog-messages"
            onTriggered: openPostInfoPage()
            tooltip: qsTr("View comments")
        },

        Action {
            iconName: "favorite"
            checkable: true
            checked: saved
            tooltip: checked ? qsTr("Unsave") : qsTr("Save")
            onCheckedChanged: rest.setSaved(fullName, checked)
            visible: rest.isLoggedIn
        }
    ]

    onClicked: {
        if (showVideoPreview)
            return;
        if (url)
            Common.openLink(url);
        else
            openPostInfoPage();
    }



    contentItem: Column {
        id: item
        anchors.fill: parent

        Loader {
            id: videoPlayerLoader
            width: parent.width
            visible: showVideoPreview

            Component.onCompleted: {
                if (!showVideoPreview)
                    return;


                setSource("qrc:///common/VideoPlayer.qml", {
                    source: previewVideo.highRes,
                    sourceWidth: previewVideo.width,
                    sourceHeight: previewVideo.height,
                    isGif: previewVideo.isGif
                });
            }
        }
        RowLayout {
            width: parent.width
            Controls.Label {
                id: label
                Layout.preferredWidth: parent.width / parent.visibleChildren.count
                text: qsTr("by %1")
                    .arg(`[${author}](http://reddit.com/u/${author})`)
                textFormat: TextEdit.MarkdownText

                LinkHandlerConnection {}
            }

            Row {
                Layout.preferredWidth: label.width


                Icon {
                    source: "clock"
                    height: label.height
                }

                Controls.Label {

                    text: qsTr("%1 ago").arg(Common.timeSince(date))
                }

            }

            Row {
                visible: !isActiveSub
                Layout.preferredWidth: label.width

                Icon {
                    source: hasIcon ? subIcon.source : ""
                    height: label.height
                    visible: hasIcon
                }

                Controls.Label {

                    text: `[${subreddit}](http://reddit.com/r/${subreddit})`
                    textFormat: TextEdit.MarkdownText

                    LinkHandlerConnection {}
                }

            }
        }


        Controls.Label {
            width: item.width
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: postContent
            visible: hasContent

            LinkHandlerConnection {}
        }
        Controls.Label {
            textFormat: TextEdit.MarkdownText

            Component.onCompleted: {
                if (flairs.count > 0)
                    visible = true;
                let newText = "";
                for (let i = 0; i < flairs.count; i++) {
                    if (i > 0)
                        newText += ", ";
                    const flairText = flairs.get(i).flairText;
                    newText += `**${flairText}**`;
                }
                 text = newText;
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
