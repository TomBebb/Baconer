import QtQuick 2.12
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.13
import QtQuick.Layouts 1.2
import "../utils/common.js" as Common
import "../common"

ScrollablePage {
    id: page
    property var postData
    property var commentsData
    readonly property bool hasContent: stringUtils.isNonEmptyString(postData.postContent)
    property bool loadingComments: false
    property int voteValue: 0

    Layout.fillWidth: true

    objectName: "PostPage"

    actions {
        main: Action {
            text: "Refresh"
            icon.name: "view-refresh"
            onTriggered: refresh(true)
            enabled: !commentsModel.loadingComments
        }
    }

    Shortcut {
        sequences: [StandardKey.Refresh, "Ctrl+R"]
        onActivated: refresh(true)
    }

    Component.onCompleted: refresh();

    supportsRefreshing: true
    onRefreshingChanged: {
        if (refreshing && !loadingComments)
            refresh(true);
    }

    title: postData.postTitle
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        id: layout
        visible: !refreshing
        Controls.Label {
            id: contentLabel
            Layout.preferredWidth: layout.width
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: postData.postContent
            visible: stringUtils.isNonEmptyString(text)

            LinkHandlerConnection {

            }
        }

        ListView {
            id: commentsList
            Layout.fillWidth: true
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds
            spacing: Units.gridUnit * 0.5
            implicitHeight: childrenRect.height


            PlaceholderMessage {
                anchors.centerIn: parent
                width: parent.width - Units.largeSpacing * 2
                visible:  commentsList.count === 0
                text: "No comments"
            }


            delegate: AbstractListItem {
                id: commentItem

                Column {
                    width: commentItem.width
                    Controls.Label {
                        id: commentText
                        color:  commentItem.textColor
                        text: stringUtils.decodeHtml(body)
                        textFormat: TextEdit.MarkdownText
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        onLinkActivated: Common.openLink(url);
                        width: parent.width
                    }
                    Controls.Label {
                        text: fmtUtils.formatDate(date)
                        color: Theme.disabledTextColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        width: parent.width
                    }
                    ActionToolBar {
                        actions: [
                            Action {
                                text: fmtUtils.formatNum(score)
                            },

                            Action {
                                iconName: "arrow-up"
                                visible: rest.isLoggedIn
                            },
                            Action {
                                iconName: "arrow-down"
                                visible: rest.isLoggedIn
                            },
                            Action {
                                text: fmtUtils.formatNum(commentCount)
                                iconName: "dialog-messages"
                                tooltip: qsTr("Reply")
                                visible: rest.isLoggedIn
                            },

                            Action {
                                iconName: "favorite"
                                checkable: true
                                tooltip: checked ? qsTr("Unsave") : qsTr("Save")
                                visible: rest.isLoggedIn
                            }
                        ]
                    }

                }

                background: Rectangle {
                    color: Theme.backgroundColor
                    border.color: Theme.positiveBackgroundColor
                    border.width: Units.smallSpacing
                    radius: Units.smallSpacing* 2

                }
            }

            model: ListModel {
                property bool loadingComments: false
                id: commentsModel
            }
        }
    }

    function refresh(forceRefresh = false) {
        loadingComments = true;
        refreshing = true;
        commentsModel.clear();
        rest.loadComments(postData, commentsModel, forceRefresh)
            .then(() => {
               loadingComments = refreshing = false;
            });
    }
}
