TARGET = qtbrowser

DESTDIR = ../
CONFIG += c++11
CONFIG -= app_bundle

SOURCES = main.cpp \
    touchmockingapplication.cpp \
    browserwindow.cpp \
    touchtracker.cpp \
    engine.cpp \
    navigationhistoryproxymodel.cpp

HEADERS = \
    touchmockingapplication.h \
    browserwindow.h \
    touchtracker.h \
    engine.h \
    navigationhistoryproxymodel.h

OTHER_FILES = \
    qml/assets/UIButton.qml \
    qml/assets/UIToolBar.qml \
    qml/ApplicationRoot.qml \
    qml/BrowserWindow.qml \
    qml/FeaturePermissionBar.qml \
    qml/MockTouchPoint.qml \
    qml/PageView.qml \
    qml/NavigationBar.qml \
    qml/HomeScreen.qml \
    qml/SettingsView.qml \

QT += qml quick webengine
QT_PRIVATE += quick-private gui-private core-private

RESOURCES += resources.qrc

!cross_compile: DEFINES += HOST_BUILD
