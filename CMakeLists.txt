CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
# enables CMakeSNAP support
SET(cmakesnap_DIR ${CMAKE_CURRENT_SOURCE_DIR}/snap)
FIND_PACKAGE(cmakesnap)
ADD_SUBDIRECTORY(snap)

CPP_BINARY(
  NAME      test_taskqueue  
  SOURCES   test_taskqueue.cpp
  HEADERS   taskqueue.hpp   
  PACKAGES  //snap/packages/boost/thread:thread
            //snap/packages/google/gtest:gtest            
            //snap/packages/google/glog:glog                 
  TEST_SIZE small                          
)

