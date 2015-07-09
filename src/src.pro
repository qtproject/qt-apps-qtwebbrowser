TARGET = qtbrowser

DESTDIR = ../
CONFIG += c++11
CONFIG -= app_bundle

SOURCES = main.cpp \
    touchmockingapplication.cpp \
    browserwindow.cpp

HEADERS = utils.h \
    touchmockingapplication.h \
    browserwindow.h

OTHER_FILES = \
    qml/assets/UIButton.qml \
    qml/ApplicationRoot.qml \
    qml/BrowserDialog.qml \
    qml/BrowserWindow.qml \
    qml/FeaturePermissionBar.qml \
    qml/LoadIndicator.qml \
    qml/MockTouchPoint.qml \
    qml/PageView.qml \
    qml/URLBar.qml \

QT += qml quick webengine
QT_PRIVATE += quick-private gui-private core-private

RESOURCES += resources.qrc

!cross_compile: DEFINES += HOST_BUILD
