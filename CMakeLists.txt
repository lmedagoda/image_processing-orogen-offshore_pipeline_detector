PROJECT(offshore_pipeline_detector)
cmake_minimum_required(VERSION 2.6)

SET (CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/.orogen/config")
INCLUDE(offshore_pipeline_detectorBase)

find_package(Boost)
include_directories(${Boost_INCLUDE_DIRS})

# FIND_PACKAGE(KDL)
# FIND_PACKAGE(OCL)

