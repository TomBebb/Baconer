import QtQuick 2.12
import QtMultimedia 5.12
import org.kde.kirigami 2.13

Column {
    property int sourceWidth
    property int sourceHeight
    property bool isGif: false
    property alias source: video.source
    
    width: parent.width
    height: childrenRect.height
    
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
    
    Video {
        id: video
        autoLoad: true
        autoPlay: isGif
        width: parent.width - Units.largeSpacing
        height: width * (sourceHeight / sourceWidth)


        loops: isGif ? MediaPlayer.Infinite : 1
        muted: isGif

        fillMode: VideoOutput.PreserveAspectCrop

        anchors.horizontalCenter: parent.horizontalCenter
        
        onPlaybackStateChanged: {
            let stackStr = "Playing";
            if (playbackState == MediaPlayer.PausedState)
                stackStr = "Paused";
            else if (playbackState == MediaPlayer.StoppedState)
                stackStr = "Stopped";
            console.debug(`${source} ${stackStr}`);
        }
    }
    Component.onCompleted: {
        console.debug("Video: width=%1, height=%2, 
source=%3".arg(width).arg(height).arg(source));
        if (video.error) {
            console.error(`Video error in ${source}: ${video.error}`);
        }
    }
}
