import QtQuick 2.0
import Ubuntu.Components 1.1
import QtMultimedia 5.0

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "videoapp.liu-xiao-guo"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(60)
    height: units.gu(85)

    property var resolution

    // This function is used to get the writable private directory of this app
    function getPriateDirectory() {
        var sharepath = "/home/phablet/.local/share/";
        var path = sharepath + applicationName;
        console.log("path: " + path);
        return path;
    }

    Page {
        id: page
        title: i18n.tr("videoapp")

        Camera {
            id: camera

            imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

            exposure {
                exposureCompensation: -1.0
                exposureMode: Camera.ExposurePortrait
            }

            flash.mode: Camera.FlashRedEyeReduction

            videoRecorder {
                onRecorderStateChanged: {
                    console.log("onRecorderStateChanged: " + videoRecorder.recorderState);
                    if (videoRecorder.recorderState === CameraRecorder.StoppedState) {
                        console.log("actualLocation: " + videoRecorder.actualLocation);
                        myvideo.source =  videoRecorder.actualLocation;
                    }
                }
            }

            videoRecorder.audioEncodingMode: videoRecorder.ConstantBitrateEncoding;
            videoRecorder.audioBitRate: 128000
            videoRecorder.mediaContainer: "mp4"
            videoRecorder.outputLocation: getPriateDirectory()

            captureMode: Camera.CaptureVideo

            Component.onCompleted: {
                resolution = camera.viewfinder.resolution;
                console.log("resolution: " + resolution.width + " " + resolution.height);
                console.log("deviceId: " + camera.deviceId)
            }
        }

        Row {
            id: container

            Item {
                width: page.width
                height: page.height

                VideoOutput {
                    id: video
                    anchors.fill: parent
                    source: camera
                    focus : visible // to receive focus and capture key events when visible
                    orientation: -90
                }

                SwipeArea {
                    anchors.fill: parent
                    onSwipe: {
                        console.log("swipe happened!： " + direction)
                        switch (direction) {
                        case "left":
                            page.state = "image";
                            break
                        }
                    }
                }
            }

            Item {
                id: view
                width: page.width
                height: page.height

                Video {
                    id: myvideo
                    anchors.fill: parent
                    autoPlay: true
                    focus: true

                    Component.onCompleted: {
                        myvideo.play();
                    }
                }

                Text {
                    text: myvideo.source
                    color:"red"
                    font.pixelSize: units.gu(2.5)
                    width: page.width
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                SwipeArea {
                    anchors.fill: parent
                    onSwipe: {
                        console.log("swipe happened!： " + direction)
                        switch (direction) {
                        case "right":
                            page.state = "";
                            break
                        }
                    }
                }
            }
        }

        states: [
            State {
                name: "playvideo"
                PropertyChanges {
                    target: container
                    x:-page.width
                }
                PropertyChanges {
                    target: capture
                    opacity:0
                }
                PropertyChanges {
                    target: stop
                    opacity:0
                }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation { target: container; property: "x"; duration: 500
                    easing.type:Easing.OutSine}
                NumberAnimation { target: capture; property: "opacity"; duration: 200}
                NumberAnimation { target: stop; property: "opacity"; duration: 200}
            }
        ]

        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: units.gu(1)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(1)

            Button {
                id: capture
                text: "Record"

                onClicked: {
                    console.log("capture path: " + getPriateDirectory());
                    camera.videoRecorder.record();
                }
            }

            Button {
                id: stop
                text: "Stop"

                onClicked: {
                    console.log("stop is clicked!");
                    camera.videoRecorder.stop();
                    page.state = "playvideo"
                }
            }

            Button {
                id: play
                text: "Play video"

                onClicked: {
                    console.log("filepath: " + myvideo.source);
                    console.log( "actual: " +  camera.videoRecorder.actualLocation);
                    myvideo.play();
                }
            }
        }

    }
}

