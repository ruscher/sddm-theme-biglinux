/***********************************************************************/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 1.1
import QtQuick.Controls 2.15 as QQC2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


// import QtQuick 2.0
import QtGraphicalEffects 1.0
import SddmComponents 2.0

import "components"


Rectangle {
    id: root
    width: 640
    height: 480
    state: "stateLogin"

    readonly property int hMargin: 40
    readonly property int vMargin: 30
    readonly property int m_powerButtonSize: 30
    readonly property color textColor: "#ffffff"

    TextConstants { id: textConstants }

    states: [
        State {
            name: "statePower"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 1}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateSession"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 1}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateUser"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 1}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateLogin"
            PropertyChanges { target: loginFrame; opacity: 1}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 0}
        }

    ]
    transitions: Transition {
        PropertyAnimation { duration: 100; properties: "opacity";  }
        PropertyAnimation { duration: 500; properties: "radius"; }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            source: config.background
            fillMode: Image.Tile
            onStatusChanged: {
                if (status == Image.Error && source !== config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        
       

        Image {
            id: mainFrameBackground
            anchors.fill: parent
            source: "wallpaper"
        }

        FastBlur {
            id: bgBlur
            anchors.fill: mainFrameBackground
            source: mainFrameBackground
            radius: 0
        }
        
        
        
        Battery {
                anchors {
                    top: parent.top
                    topMargin: units.largeSpacing + 2.5
                    right: parent.right
                    rightMargin: units.largeSpacing
                    
                }
        } 

        KeyboardButton {
            
        }                

        DropShadow {
            id: clockShadow
            anchors.fill: clock
            source: clock
            visible: !softwareRendering
            radius: 6
            samples: 14
            spread: 0.3
            color : "black" // shadows should always be black
            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.veryLongDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Clock {
            id: clock
            property Item shadow: clockShadow
            visible: y > 0

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 0  // Ajuste esta margem de acordo com sua preferência
                
            }

            Layout.alignment: Qt.AlignBaseline
        }                     
        

        Item {
            id: centerArea
            width: parent.width
            height: parent.height / 3
            anchors.top: parent.top
            anchors.topMargin: parent.height / 5

            PowerFrame {
                id: powerFrame
                anchors.fill: parent
                enabled: root.state == "statePower"
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
                onNeedShutdown: sddm.powerOff()
                onNeedRestart: sddm.reboot()
                onNeedSuspend: sddm.suspend()
            }

            SessionFrame {
                id: sessionFrame
                anchors.fill: parent
                enabled: root.state == "stateSession"
                onSelected: {
                    console.log("Selected session:", index)
                    root.state = "stateLogin"
                    loginFrame.sessionIndex = index
                    loginFrame.input.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
            }

            UserFrame {
                id: userFrame
                anchors.fill: parent
                enabled: root.state == "stateUser"
                onSelected: {
                    console.log("Select user:", userName)
                    root.state = "stateLogin"
                    loginFrame.userName = userName
                    loginFrame.input.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
            }

            LoginFrame {
                id: loginFrame
                anchors.fill: parent
                enabled: root.state == "stateLogin"
                opacity: 0
                transformOrigin: Item.Top
            }
            

            
            DropShadow {
                id: phrasesShadow
                anchors.fill: phrasesModel
                source: phrasesModel
                visible: !softwareRendering
                radius: 6
                samples: 14
                spread: 0.3
                color : "black" // shadows should always be black
                Behavior on opacity {
                    OpacityAnimator {
                        duration: PlasmaCore.Units.veryLongDuration * 2
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            PhrasesModel {
                id: phrasesModel
                //ruscher
                property Item shadow: phrasesShadow
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    bottom: sessionButton.bottom
                    bottomMargin: units.gridUnit * -7.9
                }
            }            
            
        }

        Item {
            id: powerArea
            visible: ! loginFrame.isProcessing
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.width / 3
            height: parent.height / 7

            Row {
                spacing: 20
                anchors.right: parent.right
                anchors.rightMargin: hMargin
                anchors.verticalCenter: parent.verticalCenter

                ImgButton {
                    id: sessionButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    //ruscher
                    visible: sessionFrame.isMultipleSessions()

                    normalImg: "icons/switchframe/unknow_indicator_normal.png"
                    hoverImg: "icons/switchframe/unknow_indicator_hover.png"
                    pressImg: "icons/switchframe/unknow_indicator_press.png"                    
                    
                    //normalImg: sessionFrame.getCurrentSessionIconIndicator()
                    onClicked: {
                        root.state = "stateSession"
                        sessionFrame.focus = true
                    }
                    onEnterPressed: sessionFrame.currentItem.forceActiveFocus()

                    KeyNavigation.tab: loginFrame.input
                    KeyNavigation.backtab: {
                        if (userButton.visible) {
                            return userButton
                        }
                        else {
                            return shutdownButton
                        }
                    }
                }

                ImgButton {
                    id: userButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: userFrame.isMultipleUsers()

                    normalImg: "icons/switchframe/userswitch_normal.png"
                    hoverImg: "icons/switchframe/userswitch_hover.png"
                    pressImg: "icons/switchframe/userswitch_press.png"
                    onClicked: {
                        console.log("Switch User...")
                        root.state = "stateUser"
                        userFrame.focus = true
                    }
                    onEnterPressed: userFrame.currentItem.forceActiveFocus()
                    KeyNavigation.backtab: shutdownButton
                    KeyNavigation.tab: {
                        if (sessionButton.visible) {
                            return sessionButton
                        }
                        else {
                            return loginFrame.input
                        }
                    }
                }

                ImgButton {
                    id: shutdownButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: true//sddm.canPowerOff

                    normalImg: "icons/switchframe/shutdown_normal.png"
                    hoverImg: "icons/switchframe/shutdown_hover.png"
                    pressImg: "icons/switchframe/shutdown_press.png"                    
                    onClicked: {
                        console.log("Show shutdown menu")
                        root.state = "statePower"
                        powerFrame.focus = true
                    }
                    onEnterPressed: powerFrame.shutdown.focus = true
                    KeyNavigation.backtab: loginFrame.button
                    KeyNavigation.tab: {
                        if (userButton.visible) {
                            return userButton
                        }
                        else if (sessionButton.visible) {
                            return sessionButton
                        }
                        else {
                            return loginFrame.input
                        }
                    }
                }
            }
        }

        MouseArea {
            z: -1
            anchors.fill: parent
            onClicked: {
                root.state = "stateLogin"
                loginFrame.input.forceActiveFocus()
            }
        }
    }
}
