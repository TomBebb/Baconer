import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13
import "../utils/common.js" as Common

Card {
    id: postCard
    property bool hasIcon: false
    property var subIcon: ({})
    property bool isSub: false
    readonly property string subredditURL: `/r/${subreddit}`
    readonly property int maxPostPreviewLength: 255
    readonly property bool hasContent: stringUtils.isNonEmptyString(postContent)
    readonly property real rowEachWidthMult: 0.2
    readonly property bool showImagePreview: previewImage.isValid && !showVideoPreview
    readonly property bool showVideoPreview: previewVideo.isValid
    readonly property bool showThumbnail: (!showImagePreview && stringUtils.isNonEmptyString(thumbnail))
    readonly property bool isActiveSub: root.currentPage && root.currentPage.url != null && subredditURL === root.currentPage.url

    property int voteValue: 0

    Component.onCompleted: {
        if (isSub)
            return;

        const post = postCard;

        rest.loadSubInfo("/r/"+subreddit).then(info => {
            if (!info.itemIcon)
                return;
            post.subIcon = info.itemIcon;
            post.hasIcon = info.itemIcon && info.itemIcon.source;
        }).catch(err => console.error(`Error getting sub icon: ${err}; postCard = ${post}`));
    }

    banner {
        title: postTitle
        titleLevel: 4
        titleWrapMode: Text.WrapAtWordBoundaryOrAnywhere
        source: showImagePreview && previewImage.url ? previewImage.url : ""
    }
    actions: [
        Action {
            text: fmtUtils.formatNum(score + voteValue, true)
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
            text: fmtUtils.formatNum(commentCount)
            iconName: "dialog-messages"
            onTriggered: openPostInfoPage()
            tooltip: qsTr("View comments")
        },

        Action {
            iconName: "favorite"
            checkable: true
            checked: saved
            tooltip: checked ? qsTr("Unsave") : qsTr("Save")
            onCheckedChanged: if (checked !== saved) rest.setSaved(fullName, checked)
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

                    text: fmtUtils.formatDate(date)
                }

            }

            Row {
                visible: !isActiveSub
                Layout.preferredWidth: label.width

                Icon {
                    source: hasIcon ? subIcon.source : ""
                    height: label.height
                    width: height
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
        Row {
            Theme.inherit: false
            Theme.colorSet: Theme.Window
            Theme.backgroundColor: "#b9d795"
            Theme.textColor: "#465c2b"
            Theme.highlightColor: "#89e51c"
            visible: flairs && flairs.count > 0

            width: item.width
            height: childrenRect.height

            spacing: Units.gridUnit / 2

            Repeater {
                model: flairs
                delegate: Controls.Label {
                    textFormat: TextEdit.MarkdownText
                    color: Theme.textColor
                    text: flairText
                    padding: Units.smallSpacing * 2
                    font.bold: true

                    background: Rectangle {
                        color: Theme.backgroundColor
                        radius: Units.gridUnit * 5
                    }
                }
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
