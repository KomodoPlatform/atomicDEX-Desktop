import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qt5Compat.GraphicalEffects
import QtCharts 2.3
import Qaterial 1.0 as Qaterial

import "../Components"
import "../Constants"

PieSlice {
    label: "XRP"; value: 10; color: Qaterial.Colors.yellow500;
    borderColor: theme.backgroundColor
     labelColor: 'white'; labelFont: theme.textType.head5
     borderWidth: 3
     Behavior on explodeDistanceFactor {
         NumberAnimation  {
             duration: 150
         }
     }

  onHovered: {
      if(state){
          exploded = true
          explodeDistanceFactor = 0.13
          labelVisible= true;
      }else {
          exploded = false
          labelVisible= false
          explodeDistanceFactor = 0.0
          borderWidth = 1
      }
  }
}
