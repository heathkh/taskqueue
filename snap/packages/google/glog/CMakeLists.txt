CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
INCLUDE_DIRECTORIES(${GOOGLE_ROOT})
INCLUDE_DIRECTORIES(${GOOGLE_ROOT}/glog/)
ADD_DEFINITIONS(-D_GNU_SOURCE)
#ADD_DEFINITIONS(-DHAVE_STACKTRACE)
ADD_DEFINITIONS(-Wno-sign-compare)

CPP_LIBRARY(
  NAME      glog 
  SOURCES   demangle.cc
            raw_logging.cc
            symbolize.cc
            vlog_is_on.cc
            logging.cc
            signalhandler.cc
            utilities.cc  
  HEADERS   config.h
            demangle.h
            stacktrace.h
            stl_logging.h
            logging.h
            symbolize.h
            log_severity.h
            utilities.h
            raw_logging.h
            vlog_is_on.h
  PACKAGES  //snap/packages/google/gflags:gflags
            //snap/packages/google/base:base
            SYS://threads    
  LIB_TYPE  STATIC
)
