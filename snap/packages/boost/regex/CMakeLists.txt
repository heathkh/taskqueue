CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(SRC_BASE "../libs/regex/src/")

CPP_LIBRARY (
  NAME      regex  
  SOURCES   ${SRC_BASE}/cpp_regex_traits.cpp
            ${SRC_BASE}/cregex.cpp
            ${SRC_BASE}/c_regex_traits.cpp
            ${SRC_BASE}/fileiter.cpp
            ${SRC_BASE}/icu.cpp
            ${SRC_BASE}/instances.cpp
            ${SRC_BASE}/internals.hpp
            ${SRC_BASE}/posix_api.cpp
            ${SRC_BASE}/regex.cpp
            ${SRC_BASE}/regex_debug.cpp
            ${SRC_BASE}/regex_raw_buffer.cpp
            ${SRC_BASE}/regex_traits_defaults.cpp
            ${SRC_BASE}/static_mutex.cpp
            ${SRC_BASE}/usinstances.cpp
            ${SRC_BASE}/w32_regex_traits.cpp
            ${SRC_BASE}/wc_regex_traits.cpp
            ${SRC_BASE}/wide_posix_api.cpp
            ${SRC_BASE}/winstances.cpp    
  HEADERS   concepts.hpp
            config.hpp
            icu.hpp
            mfc.hpp
            pattern_except.hpp
            regex_traits.hpp
            user.hpp    
  PACKAGES
  LIB_TYPE  STATIC           
)

 



