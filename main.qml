import QtQuick 2.4
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.1
import "content"
import "AuxFunctions.js" as AuxFunction

ApplicationWindow {
    visible: true
    width: 800
    height: 1280

//==============================================================================================
    function retrieveBusListFromServer(streetAdress) {
        var url = "https://api.appglu.com/v1/queries/findRoutesByStopName/run";
        var requestBody = "{
                           \"params\": {\"stopName\": \"%" + streetAdress + "%\"}
                           }";

        AuxFunction.getRequestResponseText(url, requestBody, parseBusLineInfo);
    }

    function retrieveBusDetailsFromServer(busId){
        var url = "https://api.appglu.com/v1/queries/findStopsByRouteId/run";
        var body = "{
                    \"params\": { \"routeId\": " + busId + "}
                    }";
        AuxFunction.getRequestResponseText(url, body, parseBusLineDetails);
    }

    function retrieveBusTimeTableFromServer(busId){
        var url = "https://api.appglu.com/v1/queries/findDeparturesByRouteId/run";
        var body = "{
                    \"params\": { \"routeId\": " + busId + "}
                    }";
        AuxFunction.getRequestResponseText(url, body, parseBusTimeTable);
    }

    property var busList: [];
    property var busNamesArray:[];

    function parseBusLineInfo(queryResponse) {
        var splitedText = queryResponse.split("]");
        var currentLine = [];
        var idInfoArray = [];
        var idInfoKey = 0;
        var busId = 0;
        var shortNameArray = [];
        var shortNameKey = "";
        var busShortName = "";
        var longNameArray =[];
        var longNameKey = "";
        var busLongName = "";
        for (var i = 0; i < splitedText.length; i++) {
            busShortName = "";
            busLongName = "";
            currentLine = splitedText[i].split(",");
            for (var j = 0; j < currentLine.length; j++) {
                var word = currentLine[j];
                if (word.search("id") > -1) {
                    idInfoArray = word.split(":");
                    idInfoKey = idInfoArray[0];
                    busId = idInfoArray[idInfoArray.length - 1];
                }
                else if (word.search("shortName") > -1) {
                    shortNameArray = word.split(":");
                    shortNameKey = shortNameArray[0];
                    busShortName = shortNameArray[1];
                }
                else if (word.search("longName") > -1) {
                    longNameArray = word.split(":");
                    longNameKey = longNameArray[0];
                    busLongName = longNameArray[1];
                 }
            }
            if ((busShortName.length > 0) && (busLongName.length > 0)) {
                busList.push([busId, busShortName, busLongName]);
                busNamesArray.push(busShortName + " - " + busLongName);
            }
        }
    }

    function getBusId(busLineDescription) {
        var busLineNumber = busLineDescription.split(" ")[0];
        for(var i = 0; i < busList.length; i++){
            var busInfo = busList[i];
            if (busInfo[1] === busLineNumber){
                return busInfo[0];
            }
        }
    }

    function loadBusDetails(busLineDescription){
        var busId = getBusId(busLineDescription);
        retrieveBusDetailsFromServer(busId);
        retrieveBusTimeTableFromServer(busId);
    }

//==============================================================================================

    MessageDialog {
        id: emptySearchStringMessageDialog
        text: qsTr("You need to insert a valid street name so we can proceed")
    }

    MessageDialog {
        id: timeoutMessageDialog
        text: qsTr("Sorry, we had a problem connecting with our server. Please try again")
    }

    Rectangle {
        color: "#212126"
        anchors.fill: parent
    }

    toolBar: BorderImage {
        border.bottom: 8
        source: "images/toolbar.png"
        width: parent.width
        height: 100

        Rectangle {
            id: backButton
            width: opacity ? 60 : 0
            anchors.left: parent.left
            anchors.leftMargin: 20
            opacity: stackView.depth > 1 ? 1 : 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            height: 60
            radius: 4
            color: backmouse.pressed ? "#222" : "transparent"
            Behavior on opacity { NumberAnimation{} }
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "images/navigation_previous_item.png"
            }
            MouseArea {
                id: backmouse
                anchors.fill: parent
                anchors.margins: -10
                onClicked: stackView.pop()
            }
        }

        Text {
            font.pixelSize: 42
            Behavior on x { NumberAnimation{ easing.type: Easing.OutCubic} }
            x: backButton.x + backButton.width + 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            text: qsTr("Bus Lines")
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        // Implements back key navigation
        focus: true
        Keys.onReleased: if (event.key === Qt.Key_Back && stackView.depth > 1) {
                             stackView.pop();
                             event.accepted = true;
                         }

        initialItem: Item {
            width: parent.width
            height: parent.height
            Item {
                width: parent.width
                height: parent.height

                property real progress: 0
                SequentialAnimation on progress {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation {
                        from: 0
                        to: 1
                        duration: 3000
                    }
                    NumberAnimation {
                        from: 1
                        to: 0
                        duration: 3000
                    }
                }

                Column {
                    spacing: 40
                    anchors.centerIn: parent

                    TextField {
                        id: textFieldSearchInput
                        anchors.margins: 20
                        placeholderText: qsTr("Type the street adress here")
                        style: textFieldStyle
                    }
                 Button {
                        style: searchButtonStyle
                        text: qsTr("Search")
                        onClicked: {
                            busNamesArray.length = 0;
                            if (textFieldSearchInput.text.length > 0) {
                                retrieveBusListFromServer(textFieldSearchInput.text);
                                httpResponseTimer.timerCount = 0;
                                httpResponseTimer.start();
                            }
                            else
                                emptySearchStringMessageDialog.open();
                        }
                        Item {
                            Timer {
                                id: httpResponseTimer
                                interval: 1000; running: false; repeat: false
                                property int timerCount: 0
                                onTriggered: {
                                    if (busNamesArray.length > 0) {
                                        stackView.push({item:Qt.resolvedUrl("content/ListPage.qml"), properties:{searchArray:busNamesArray, busIdList:busList}});
                                        textFieldSearchInput.text = "";
                                    }
                                    else {
                                        timerCount++;
                                        (timerCount > 5) ? timeoutMessageDialog.open() : start();
                                    }
                                }
                            }
                        }
                }
                Component {
                    id: textFieldStyle

                    TextFieldStyle {
                        textColor: "white"
                        placeholderTextColor: "gray"
                        background: Item {
                            implicitHeight: 50
                            implicitWidth: 450
                            BorderImage {
                                source: "../images/textinput.png"
                                border.left: 8
                                border.right: 8
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                            }
                        }
                    }
                }

                Component {
                    id: searchButtonStyle
                    ButtonStyle {
                        panel: Item {
                            implicitHeight: 50
                            implicitWidth: 320
                            BorderImage {
                                anchors.fill: parent
                                antialiasing: true
                                border.bottom: 8
                                border.top: 8
                                border.left: 8
                                border.right: 8
                                anchors.margins: control.pressed ? -4 : 0
                                source: control.pressed ? "../images/button_pressed.png" : "../images/button_default.png"
                                Text {
                                    text: control.text
                                    anchors.centerIn: parent
                                    color: "white"
                                    font.pixelSize: 24
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }
        }
      }
    }
}
