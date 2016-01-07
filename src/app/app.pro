TARGET = qtwebbrowser

DESTDIR = ../
CONFIG += c++11
CONFIG -= app_bundle

SOURCES = main.cpp \
    browserwindow.cpp \
    engine.cpp

HEADERS = browserwindow.h \
    engine.h

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

RESOURCES += resources.qrc

!cross_compile {
    DEFINES += HOST_BUILD
    SOURCES += touchmockingapplication.cpp \
            navigationhistoryproxymodel.cpp \
            touchtracker.cpp

    HEADERS += touchmockingapplication.h \
                navigationhistoryproxymodel.h \
                touchtracker.h

    QT_PRIVATE += quick-private gui-private core-private
}
else {
    DESTPATH = /data/user/qt/qtwebbrowser

    content.files = qml/*
    content.path = $$DESTPATH
    target.path = $$DESTPATH

    INSTALLS += target content
}



