import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

ScrollView {
    width: parent.width
    height: parent.height
    horizontalScrollBarPolicy: 0

    flickableItem.interactive: true

    function populateBusInfoListView(){
        busStreetsModel.append({"busStreet":qsTr("BEGIN")});
        for(var i = 0; i < lineRoadsArray.length; i++){
            busStreetsModel.append({"busStreet":lineRoadsArray[i]});
        }
        busStreetsModel.append({"busStreet":qsTr("FINISH")});
    }

    Component.onCompleted: {
            busStreetsModel.clear();
            populateBusInfoListView();
    }

    Item{
        ListModel {
            id: busStreetsModel
        }
    }
    ListView {
        id: busStreetsInfoList
        interactive: true
        boundsBehavior: Flickable.DragOverBounds
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        model: busStreetsModel
        delegate: BusStreetDelegate {
            text: busStreet
        }
    }

    style: ScrollViewStyle {
        transientScrollBars: true
        handle: Item {
            implicitWidth: 14
            implicitHeight: 26
            Rectangle {
                color: "#424246"
                anchors.fill: parent
                anchors.topMargin: 6
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.bottomMargin: 6
            }
        }
        scrollBarBackground: Item {
            implicitWidth: 14
            implicitHeight: 26
        }
    }
}

