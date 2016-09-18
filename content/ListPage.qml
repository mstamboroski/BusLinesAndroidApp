import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1


ScrollView {
    width: parent.width
    height: parent.height

    flickableItem.interactive: true

    property var searchArray: [];
    property var busIdList:[];

    function populateListView(){
        for(var i = 0; i < searchArray.length; i++){
            busInfoModel.append({"busInfo":searchArray[i]});
        }
    }

    Component.onCompleted: {
            busInfoModel.clear();
            populateListView();
        }
    Item{
        ListModel {
            id: busInfoModel
        }
    }
    ListView {
        id: busInfoList
        anchors.fill: parent
        model: busInfoModel
        delegate: BussesNamesDelegate {
            text: busInfo
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
