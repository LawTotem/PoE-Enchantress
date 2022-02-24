
cmake_minimum_required(VERSION 3.0)

set(CMAKE_CXX_STANDARD 17)

project(PoE-Enchantress)

add_library(snipper MODULE
    ${CMAKE_SOURCE_DIR}/tools/snipper/snipper.cpp
    ${CMAKE_SOURCE_DIR}/tools/snipper/JSON.cpp
    ${CMAKE_SOURCE_DIR}/tools/snipper/JSONValue.cpp
    ${CMAKE_SOURCE_DIR}/tools/snipper/JSON.h
    ${CMAKE_SOURCE_DIR}/tools/snipper/JSONValue.h
)

#set_target_properties(snipper PROPERTIES ENABLE_EXPORTS True)

#set_target_properties(snipper PROPERTIES COMPILE_FLAGS "/DLL" LINK_FLAGS "/DEF:${CMAKE_SOURCE_DIR}/tools/snipper/exports.def /DLL")

target_include_directories(snipper
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/tools/snipper
    ${CMAKE_SOURCE_DIR}/tools/TensorFlow/include
)

target_link_directories(snipper
    PRIVATE
    ${CMAKE_SOURCE_DIR}/tools/TensorFlow/lib
)

target_link_libraries(snipper
    tensorflow
    GDIPlus
    gdi32
    user32
)
