TEMPLATE = aux

build_online_docs: \
    QMAKE_DOCS = $$PWD/online/qtwebbrowser.qdocconf
else: \
    QMAKE_DOCS = $$PWD/qtwebbrowser.qdocconf

DISTFILES += \
     $$PWD/src/qtwebbrowser.qdoc \
     $$PWD/src/external-resources.qdoc \
     $$PWD/qtwebbrowser-project.qdocconf \
     $$PWD/qtwebbrowser.qdocconf \
     $$PWD/online/qtwebbrowser.qdocconf \
     $$PWD/images/src/block-diagram.qmodel
