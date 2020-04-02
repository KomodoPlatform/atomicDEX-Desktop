import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.0
import "../Components"
import "../Constants"

Item {
    function disconnect() {
        API.get().disconnect()
        onDisconnect()
    }

    function reset() {

    }

    function onOpened() {
        if(mm2_version === '') mm2_version = API.get().get_mm2_version()
    }

    property string mm2_version: ''
    property var fiats: (["USD", "EUR"])

    ColumnLayout {
        anchors.centerIn: parent
        DefaultText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Style.textSize2
            text: API.get().empty_string + (qsTr("Settings"))
        }

        Rectangle {
            color: Style.colorTheme7
            radius: Style.rectangleCornerRadius

            Layout.alignment: Qt.AlignHCenter

            width: layout.childrenRect.width + layout.anchors.leftMargin * 2
            height: layout.childrenRect.height + layout.anchors.topMargin * 2

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.top: parent.top
                anchors.topMargin: anchors.leftMargin
                id: layout

                ComboBoxWithTitle {
                    id: combo_fiat
                    title: API.get().empty_string + (qsTr("Fiat"))
                    Layout.fillWidth: true

                    field.model: fiats
                    field.onCurrentIndexChanged: {
                        API.get().fiat = fiats[field.currentIndex]
                    }
                    Component.onCompleted: {
                        field.currentIndex = fiats.indexOf(API.get().fiat)
                    }
                }

                Languages {
                    Layout.alignment: Qt.AlignHCenter
                }

                HorizontalLine {
                    Layout.fillWidth: true
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Open Logs Folder"))
                    onClicked: Qt.openUrlExternally("file:///" + API.get().get_log_folder())
                }

                DangerButton {
                    text: API.get().empty_string + (qsTr("Delete Wallet"))
                    Layout.fillWidth: true
                    onClicked: {
                        API.get().delete_wallet(API.get().wallet_default_name)
                        disconnect()
                    }
                }

                DefaultButton {
                    Layout.fillWidth: true
                    text: API.get().empty_string + (qsTr("Log out"))
                    onClicked: disconnect()
                }
            }
        }
    }

    DefaultText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: anchors.bottomMargin
        text: API.get().empty_string + (qsTr("mm2 version") + ":    " + mm2_version)
        font.pixelSize: Style.textSizeSmall
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
