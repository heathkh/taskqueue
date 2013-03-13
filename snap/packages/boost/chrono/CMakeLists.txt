CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(SRC_BASE "../libs/chrono/src/")

CPP_LIBRARY (
  NAME      chrono  
  SOURCES   ${SRC_BASE}/chrono.cpp      
            ${SRC_BASE}/process_cpu_clocks.cpp
            ${SRC_BASE}/thread_clock.cpp    
  HEADERS   ceil.hpp
            chrono.hpp
            chrono_io.hpp
            clock_string.hpp
            config.hpp
            duration.hpp
            floor.hpp
            include.hpp
            process_cpu_clocks.hpp
            round.hpp
            system_clocks.hpp
            thread_clock.hpp
            time_point.hpp       
  PACKAGES  SYS://rt
  LIB_TYPE  STATIC           
)



