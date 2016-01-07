CXX_MODULE = qml
TARGET = webbrowser
TARGETPATH = WebBrowser
QT += qml quick
CONFIG += qt

SOURCES += \
    plugin.cpp

load(qml_plugin)

target.path += /data/user/qt/qmlplugins/WebBrowser
INSTALLS += target




