CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

INCLUDE_DIRECTORIES(${GOOGLE_ROOT}/base)

CPP_LIBRARY(
  NAME      base 
  SOURCES   hashutils.cc  int128.cc  stringprintf.cc  strtoint.cc
  HEADERS   basictypes.h        hashutils.h       port.h           strtoint.h
            casts.h             int128.h          stl_decl.h       template_util.h
            commandlineflags.h  integral_types.h  stl_decl_msvc.h  type_traits.h
            config.h            macros.h          stl_decl_osx.h   
            googleinit.h        mutex.h           stringprintf.h   
  PACKAGES  SYS://openssl
            SYS://threads
  LIB_TYPE  STATIC_AND_SHARED  
)

