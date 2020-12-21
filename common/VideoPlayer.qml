import QtQuick 2.0
import QtMultimedia 5.15

Video {
    anchors.fill: parent
    id: video
    width : parent.width
    height : parent.height

    MouseArea {
        anchors.fill: parent
        onClicked: {
            video.play()
        }
    }

    focus: true
    Keys.onSpacePressed: video.playbackState == MediaPlayer.PlayingState ? video.pause() : video.play()
    Keys.onLeftPressed: video.seek(video.position - 5000)
    Keys.onRightPressed: video.seek(video.position + 5000)
    onPlaybackStateChanged:
        console.debug(`Playback state for vid: ${playbackState}`);
}
