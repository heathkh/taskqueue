CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

INCLUDE_DIRECTORIES(${GOOGLE_ROOT}) 

CPP_LIBRARY(
  NAME      gflags 
  SOURCES   gflags.cc gflags_reporting.cc gflags_completions.cc
  HEADERS   gflags.h
  LIB_TYPE  STATIC
)
