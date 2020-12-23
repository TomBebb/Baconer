import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import QtWebView 1.1
import org.kde.kirigami 2.13
import "../utils/common.js" as Common

Card {
    id: postCard
    property bool hasIcon: false
    property var subIcon: ({})
    property bool isSub: false
    property bool isPreview: true
    readonly property string subredditURL: "/r/"+subreddit
    readonly property int maxPostPreviewLength: 255
    readonly property bool hasContent: stringUtils.isNonEmptyString(postContent)
    readonly property real rowEachWidthMult: 0.2
    readonly property bool showImagePreview: previewImage.isValid && !showVideoPreview
    readonly property bool showVideoPreview: previewVideo.isValid
    readonly property bool isActiveSub: root.currentPage && root.currentPage.url != null && subredditURL === root.currentPage.url
    property bool canShowEmbed: false
    property var oembedData: null
    property int voteValue: 0

    function showEmbed() {
        banner.source = "";
        oembedLoader.visible = true;
        oembedLoader.setSource("qrc:///common/EmbeddedWebView.qml", {
            initialURL: oembedData.url,
            initialHTML: oembedData.html
        });

        canShowEmbed = false;
    }

    Component.onCompleted: {
        if (showVideoPreview) {
            
            console.debug(`Show video: ${postTitle}`);
            videoPlayerLoader.visible = true;
            videoPlayerLoader.setSource("qrc:///common/VideoPlayer.qml", {
                source: previewVideo.highRes,
                sourceWidth: previewVideo.width,
                sourceHeight: previewVideo.height,
                isGif: previewVideo.isGif
            });
            return;
        }
        console.debug(`Try embed: ${postTitle}`);
        const oembed = rest.tryOembed(url).then(function(data) {
            if (data === null)
                return;
            canShowEmbed = true;
            oembedData = data;
        }).catch(function(err) {
            console.error(qsTr("Error while embedding %1: %2".arg(url).arg(err)));
        });

        if (!isPreview) {
            // auto-embed if post is viewed directly
            oembed.then(showEmbed);
        }

        if (isSub)
            return;

        const post = postCard;

        rest.loadSubInfo("/r/"+subreddit).then(function(info) {
            if (!info.itemIcon)
                return;
            post.subIcon = info.itemIcon;
            post.hasIcon = info.itemIcon && info.itemIcon.source;
        }).catch(function(err) {
            console.error(qsTr("Error getting subreddit icon for %1: %2")
                .arg(subreddit)
                .arg(err)
            );
        });
    }

    banner {
        title: postTitle
        titleLevel: 3
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
        if (canShowEmbed)
            showEmbed();
        else if (url)
            Common.openLink(url);
        else
            openPostInfoPage();
    }


    contentItem: Column {
        id: item
        anchors.fill: parent
        
        
        Loader {
            id: videoPlayerLoader
            visible: showVideoPreview
            width: parent.width
        }
        Loader {
            id: oembedLoader
            width: parent.width
            height: width * (9 / 16)
            visible: false
        }
        RowLayout {
            width: parent.width
            Controls.Label {
                id: label
                Layout.preferredWidth: parent.width / parent.visibleChildren.count
                text: qsTr("by [%1](http://reddit.com/u/%1)")
                    .arg(author)
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

                    text: "[%1](http://reddit.com/r/%1)"
                        .arg(subreddit)
                    textFormat: TextEdit.MarkdownText

                    LinkHandlerConnection {}
                }

            }
        }


        Controls.Label {
            width: item.width
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: isPreview ? stringUtils.tidyDesc(postContent, 255) : postContent
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
            .then(root.openPage)
            .catch(function(err) {
                console.error(qsTr("Error loading post info page: %1").arg(err));
            });
    }

}
