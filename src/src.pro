TEMPLATE = subdirs
SUBDIRS += \
    app

cross_compile {
    SUBDIRS += \
        imports
}
