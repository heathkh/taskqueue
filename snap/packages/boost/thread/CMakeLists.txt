CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

SET(SRC_BASE "../libs/thread/src/")

CPP_LIBRARY (
  NAME      thread  
  SOURCES   ${SRC_BASE}/future.cpp
            ${SRC_BASE}/tss_null.cpp
            ${SRC_BASE}/pthread/once.cpp
            ${SRC_BASE}/pthread/thread.cpp                          
  HEADERS   
  PACKAGES  //snap/packages/boost/system:system
            SYS://rt
  LIB_TYPE  STATIC           
)


