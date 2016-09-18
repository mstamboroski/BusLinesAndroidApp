import QtQuick 2.2

Item {
    id: root
    width: parent.width
    height: 88

    property alias text: textitem.text

    Text {
        id: textitem
        color: "white"
        font.pixelSize: 32
        text: busStreet
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 30
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15
        height: 1
        color: "#424246"
    }
}
