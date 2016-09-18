TEMPLATE = app

QT += qml quick

CONFIG += c++11

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    images/button_default.png \
    images/button_pressed.png \
    images/navigation_next_item.png \
    images/navigation_previous_item.png \
    images/tab_selected.png \
    images/tabs_standard.png \
    images/textinput.png \
    images/toolbar.png \
    content/BussesNamesDelegate.qml \
    content/BusStreetDelegate.qml \
    content/ListPage.qml \
    content/StreetNamesPage.qml \
    content/TabBarPage.qml \
    content/TimeTablePage.qml \
    AuxFunctions.js \
    main.qml
