CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
SET(SRC_BASE "../libs/timer/src/")
CPP_LIBRARY(
  NAME      timer  
  SOURCES   ${SRC_BASE}/auto_timers_construction.cpp          
            ${SRC_BASE}/cpu_timer.cpp
  HEADERS    
  PACKAGES  //snap/boost/chrono:chrono   
  LIB_TYPE  STATIC           
)



 