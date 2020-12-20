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
    readonly property bool showImagePreview: previewImage.isValid
    readonly property bool showThumbnail: (!showImagePreview && Common.isNonEmptyString(thumbnail))
    readonly property bool isActiveSub: root.currentPage && root.currentPage.url != null && subredditURL === root.currentPage.url
    property int voteValue: 0


    banner {
        title: postTitle
        titleLevel: 4
        titleWrapMode: Text.WrapAtWordBoundaryOrAnywhere
        source: previewImage.url ? previewImage.url : ""
    }
    actions: [
        Action {
            text: Common.formatNum(score + voteValue)
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
        if (url)
            Common.openLink(url);
        else
            openPostInfoPage();
    }

    contentItem: Item {
        id: item
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight


        ColumnLayout {
            id: delegateLayout
            width: parent.width
            height: parent.height


            RowLayout {
                Layout.preferredWidth: item.width

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
                Layout.fillWidth: true
                Layout.preferredWidth:  item.width
                textFormat: TextEdit.MarkdownText
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: postContent
                visible: hasContent

                LinkHandlerConnection {}
            }
            Controls.Label {
                font.bold: true
                visible: false

                Component.onCompleted: {
                    if (flairs.count > 0)
                        visible = true;
                    let newText = "";
                    for (let i = 0; i < flairs.count; i++) {
                        if (i > 0)
                            newText += ", ";
                        newText += flairs.get(i).flairText;
                    }
                     text = newText;
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
