import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

Item {
    width: parent.width
    height: parent.height

    function mountColumns (rowTitle, timeRows){
        var dayFirstRow = "";
            for(var i = 0; (i < timeRows.length) && (i < 3) ; i++){
                dayFirstRow = dayFirstRow + "    "  + timeRows[i];
            }
            timeTableModel.append({day: qsTr(rowTitle),
                                  time: dayFirstRow});
            var dayRow = "";
            for(i = 3; i < timeRows.length; i++){
                if (((i % 3) === 0) && (dayRow.length > 0)) {
                    timeTableModel.append({day: "",
                                          time: dayRow});
                    dayRow = "";
                }
                dayRow = dayRow + "    "  + timeRows[i];
            }
            if (dayRow.length > 0) {
                timeTableModel.append({day: "",
                                      time: dayRow});
                dayRow = "";
            }
            timeTableModel.append({day: qsTr(""),
                                  time: ""});
        }

    function populateTableView(){
        var weekdayString = qsTr("WEEKDAY");
        var saturdayString = qsTr("SATURDAY");
        var sundayString = qsTr("SUNDAY");
        var noBussesString = qsTr("The line doesn't operate on this day");

        if (lineWeekdayTable.length > 0)
            mountColumns(weekdayString, lineWeekdayTable);
        else
            timeTableModel.append({day: qsTr(weekdayString),
                                  time: noBussesString});

        if (lineSaturdayTable.length > 0)
            mountColumns(saturdayString, lineSaturdayTable);
        else
            timeTableModel.append({day: qsTr(saturdayString),
                                  time: noBussesString});

        if (lineSundayTable.length > 0)
            mountColumns(sundayString, lineSundayTable);
        else
            timeTableModel.append({day: qsTr(sundayString),
                                  time: noBussesString});
    }

    Component.onCompleted: {
            timeTableModel.clear();
            populateTableView();
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.fill: parent
        spacing: 12

        TableView {
            id: timeTableView
            anchors.fill: parent
            TableViewColumn {
                id: dayTableColumn
                movable: false
                resizable: false
                role: "day"
                //title: qsTr("Day of the week")
                width: timeTableView.viewport.width /3
            }
            TableViewColumn {
                role: "time"
                movable: false
                resizable: false
                width: timeTableView.viewport.width - dayTableColumn.width
            }
            itemDelegate: Item {
                            Text {
                                text: styleData.value
                                font.pixelSize: 26
                                color: "white"
                            }
            }
            model: timeTableModel
            style: TableViewStyle{
                backgroundColor: "#212126"
                alternateBackgroundColor: "#212126"
                headerDelegate:Text {
                    text: styleData.value
                    color: "white"
                }
            }
        }
    }
    ListModel {
                id: timeTableModel
    }
}
