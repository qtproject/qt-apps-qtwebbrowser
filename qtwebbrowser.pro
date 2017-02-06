TEMPLATE = subdirs
SUBDIRS = src

requires(qtHaveModule(webengine))

QTWEBBROWSER_VERSION = 1.0.0
QTWEBBROWSER_VERSION_TAG = 100

include(doc/doc.pri)
