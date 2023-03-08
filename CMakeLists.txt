cmake_minimum_required(VERSION 3.16)
project(qtwebbrowser LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick WebEngineQuick VirtualKeyboard)

set(SOURCES
    src/appengine.cpp
    src/appengine.h
    src/main.cpp
    src/navigationhistoryproxymodel.cpp
    src/navigationhistoryproxymodel.h
    src/touchtracker.cpp
    src/touchtracker.h
)
if(NOT CMAKE_CROSSCOMPILING)
    list(APPEND SOURCES
        src/touchmockingapplication.cpp
        src/touchmockingapplication.h
    )
endif()
qt_add_resources(SOURCES src/resources.qrc)

qt_add_executable(qtwebbrowser ${SOURCES})

set_target_properties(qtwebbrowser PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(qtwebbrowser PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::WebEngineQuick
    Qt::VirtualKeyboard
)
if(NOT CMAKE_CROSSCOMPILING)
    target_compile_definitions(qtwebbrowser
        PRIVATE DESKTOP_BUILD=1
    )
    target_link_libraries(qtwebbrowser PRIVATE
        Qt::GuiPrivate
    )
    if(NOT DEFINED CMAKE_INSTALL_PREFIX)
        set(CMAKE_INSTALL_PREFIX "/usr/local/bin")
    endif()
else()
    if(NOT DEFINED CMAKE_INSTALL_PREFIX)
        set(CMAKE_INSTALL_PREFIX "/data/user/qt/qtwebbrowser-app")
    endif()
endif()
