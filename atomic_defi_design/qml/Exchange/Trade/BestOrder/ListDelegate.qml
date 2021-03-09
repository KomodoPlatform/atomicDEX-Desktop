import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15


import Qaterial 1.0 as Qaterial

import "../../../Components"
import "../../../Constants"

Item {
    id: _control
    property bool isAsk: Math.random() < 0.5;
    width: visible? list.width : 0
    height: 36


    AnimatedRectangle {
        visible: mouse_are.containsMouse
        width: parent.width
        height: parent.height
        color: Style.colorWhite1
        opacity: 0.1
        anchors.left: parent.left
    }

    RowLayout {
        id: row
        width:  parent.width - 30
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Row {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 90
            leftPadding: -10
            spacing: 5
            Image {
                source: General.coinIcon((isAsk? "RVN": "KMD"))
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
            }
            DefaultText {
                anchors.verticalCenter: parent.verticalCenter
                leftPadding: 2
                text: parseFloat(Math.random(522222)).toFixed(8) + (isAsk? " RVN": " KMD")
                font.pixelSize: Style.textSizeSmall1

            }
        }

        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 70
            text: parseFloat(Math.random()*(Math.random()*3)*1.5).toFixed(2)+"$"
            font.pixelSize: Style.textSizeSmall1
            horizontalAlignment: Label.AlignRight
            opacity: 1

        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true


        }
        DefaultText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 120
            text: parseFloat(Math.random()*(Math.random()*3)*9.5).toFixed(2)+"%"
            Behavior on rightPadding {
                NumberAnimation {
                    duration: 150
                }
            }
            color: isAsk? Style.colorRed : Style.colorGreen
            horizontalAlignment: Label.AlignRight
            font.pixelSize: Style.textSizeSmall1
            opacity: 1

        }
    }


    DefaultMouseArea {
        id: mouse_are
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            //if(is_mine) return
            //isAsk? selectOrder(true, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume) : selectOrder(false, coin, price, quantity, price_denom, price_numer, quantity_denom, quantity_numer, min_volume)
        }
    }
    HorizontalLine {
        width: parent.width
    }

}