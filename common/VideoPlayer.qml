import QtQuick 2.12
import QtMultimedia 5.12
import org.kde.kirigami 2.13

Column {
    property int sourceWidth
    property int sourceHeight
    property bool isGif: false
    property alias source: video.source
    //anchors.fill: parent
    width: parent.width
    height: childrenRect.height
    Video {
        id: video

        autoLoad: true
        autoPlay: isGif
        clip: true


        loops: isGif ? MediaPlayer.Infinite : 1
        muted: isGif

        fillMode: VideoOutput.PreserveAspectCrop


        width: parent.width
        height: width * (sourceHeight / sourceWidth)

        anchors.horizontalCenter: parent.horizontalCenter
    }

    ActionToolBar {
        width: parent.width
        actions: [
            Action {
                text: "Pause"
                iconName: "media-playback-pause"
                visible: video.playbackState === MediaPlayer.PlayingState
                onTriggered: video.pause()
            },
            Action {
                text: video.playbackState === MediaPlayer.PausedState ? "Resume" : "Start"
                iconName: "media-playback-start"
                visible: video.playbackState !== MediaPlayer.PlayingState
                onTriggered: video.play()
            },
            Action {
                text: video.muted ? "" : "Mute"
                iconName: video.muted ? "audio-volume-high" : "audio-volume-muted"
                visible: video.hasAudio
                onTriggered: video.muted = !video.muted
            }

        ]
    }
}
