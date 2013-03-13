CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
SET(SRC_BASE "../libs/system/src/")
CPP_LIBRARY (
  NAME      system  
  SOURCES   ${SRC_BASE}/error_code.cpp
            ${SRC_BASE}/local_free_on_destruction.hpp
  HEADERS   api_config.hpp
            config.hpp
            cygwin_error.hpp
            error_code.hpp
            linux_error.hpp
            system_error.hpp
            windows_error.hpp
  PACKAGES     
  LIB_TYPE  STATIC           
)



 