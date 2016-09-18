import QtQuick 2.2
import QtQuick.Dialogs 1.1
import "../AuxFunctions.js" as AuxFunction

Item {
    id: root
    width: parent.width
    height: 88

    property alias text: textitem.text
    signal clicked

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

    property var lineDetailsArray: [];
    property var lineWeekdayTimeArray: [];
    property var lineSaturdayTimeArray: [];
    property var lineSundayTimeArray: [];

    function parseBusLineDetails(queryResponse) {
        var splitedQuery = queryResponse.split("}");
        var currentLine = [];
        var streetName = "";
        for (var i = 0; i < splitedQuery.length; i++) {
            streetName = "";
            currentLine = splitedQuery[i].split(",");
            for (var j = 0; j < currentLine.length; j++) {
                var word = currentLine[j];
                if (word.search("name") > -1) {
                    var streetNameArray = word.split(":");
                    streetName = streetNameArray[streetNameArray.length - 1];
                }
            }
            if (streetName.length > 0)
                lineDetailsArray.push(streetName);
        }
    }

        function parseBusTimeTable(queryResponse){
            var splitedQuery = queryResponse.split("}");
            var currentLine = [];
            var timeLine = [];
            var day = "";
            var time = "";
            for (var i = 0; i < splitedQuery.length; i++) {
                day = "";
                currentLine = splitedQuery[i].split(",");
                for (var j = 0; j < currentLine.length; j++) {
                    var word = currentLine[j];
                    if (word.search("calendar") > -1) {
                        var streetNameArray = word.split(":");
                        day = streetNameArray[streetNameArray.length - 1];
                        timeLine = currentLine[++j].split(":");
                        console.log(timeLine);
                        time = timeLine[timeLine.length - 2] + ":" + timeLine[timeLine.length - 1];
                    }
                }
                if (day.length > 0) {
                    if (day === "\"WEEKDAY\"")
                        lineWeekdayTimeArray.push(time);
                    else if(day === "\"SATURDAY\"")
                        lineSaturdayTimeArray.push(time);
                    else
                        lineSundayTimeArray.push(time);
                }
            }
        }

    MessageDialog {
        id: timeoutMessageDialog
        text: qsTr("Sorry, we had a problem connecting with our server. Please try again")
    }

    Rectangle {
        anchors.fill: parent
        color: "#11ffffff"
        visible: mouse.pressed
    }

    Text {
        id: textitem
        color: "white"
        font.pixelSize: 32
        text: modelData
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

    Image {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        source: "../images/navigation_next_item.png"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            root.clicked();
            lineDetailsArray.length = 0;
            lineWeekdayTimeArray.length = 0;
            lineSaturdayTimeArray.length = 0;
            lineSundayTimeArray.length = 0;
            loadBusDetails(parent.text);
            httpResponseTimer.timerCount = 0;
            httpResponseTimer.start();
        }
        Item {
            Timer {
                id: httpResponseTimer
                interval: 1000; running: false; repeat: false
                property int timerCount: 0
                onTriggered: {
                    if ((lineDetailsArray.length > 0) && (lineWeekdayTimeArray.length > 0)) {
                        console.log(lineWeekdayTimeArray);
                        stackView.push({item:Qt.resolvedUrl("TabBarPage.qml"), properties:{lineRoadsArray:lineDetailsArray,
                                                                                           lineWeekdayTable:lineWeekdayTimeArray,
                                                                                           lineSaturdayTable:lineSaturdayTimeArray,
                                                                                           lineSundayTable:lineSundayTimeArray
                                                                                           }});
                    }
                    else {
                        timerCount++;
                        (timerCount > 10) ? timeoutMessageDialog.open() : start();
                    }
                }
            }
        }
    }
}
