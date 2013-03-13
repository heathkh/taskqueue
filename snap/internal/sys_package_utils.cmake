# Helps simplify a lot of boilerplate code for finding system install libraries.
MACRO(FIND_SNAP_SYS_PACKAGE)
  SET(FIND_SNAP_SYS_PACKAGE_ARGS "${ARGN}")
  CMAKE_PARSE_ARGUMENTS("SNAP_FIND_SYS" # Arg prefix is just "_" 
                          "" # Option type arguments
                          "NAME" # Single value arguments
                          "LIBRARY_NAMES;LIBRARY_SEARCH_PATHS;PATH_TO_A_HEADER;INCLUDE_SEARCH_PATHS;" # List valued arguments 
                          ${FIND_SNAP_SYS_PACKAGE_ARGS} )
  REQUIRE_NOT_EMPTY(SNAP_FIND_SYS_NAME SNAP_FIND_SYS_LIBRARY_NAMES SNAP_FIND_SYS_PATH_TO_A_HEADER)    
  IF(SNAP_FIND_SYS_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${SNAP_FIND_SYS_UNPARSED_ARGUMENTS}")
  ENDIF()
  
  # Try to detect the include path by finding an example header file
  FIND_PATH(${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS NAMES ${SNAP_FIND_SYS_PATH_TO_A_HEADER} PATHS ${SNAP_FIND_SYS_INCLUDE_SEARCH_PATHS})
  IF(NOT DEFINED ${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS)
    MESSAGE(FATAL_ERROR "Failed to find header: ${SNAP_FIND_SYS_PATH_TO_A_HEADER}")    
  ENDIF()
  
  # Try to find the path to all the directly required libraries
  SET(${SNAP_FIND_SYS_NAME}_LIBRARIES "")
  FOREACH(curLibName ${SNAP_FIND_SYS_LIBRARY_NAMES})
    FIND_LIBRARY(CUR_LIBRARY_PATH NAMES ${curLibName} PATHS ${SNAP_FIND_SYS_LIBRARY_SEARCH_PATHS})               
    IF(NOT CUR_LIBRARY_PATH)
      MESSAGE(FATAL_ERROR "Can't find lib: ${curLibName}")
    ENDIF()
    LIST(APPEND ${SNAP_FIND_SYS_NAME}_LIBRARIES ${CUR_LIBRARY_PATH})
    UNSET(CUR_LIBRARY_PATH CACHE) # calling FIND_LIBRARY added something to the cache we don't want... this clears it           
  ENDFOREACH(curLibName ${libNames})  
  
  LIST(LENGTH SNAP_FIND_SYS_LIBRARY_NAMES requested_num_libs)
  LIST(LENGTH ${SNAP_FIND_SYS_NAME}_LIBRARIES found_num_libs)
  IF(NOT ${found_num_libs} EQUAL ${requested_num_libs})
    MESSAGE(ERROR "Requested ${requested_num_libs} but found ${found_num_libs}.")
    MESSAGE(ERROR "Requested: ${SNAP_FIND_SYS_LIBRARY_NAMES}")
    MESSAGE(ERROR "Found: ${${SNAP_FIND_SYS_NAME}_LIBRARIES}")
    SET(${SNAP_FIND_SYS_NAME}_FOUND FALSE)
  ELSEIF(NOT ${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS)
    SET(${SNAP_FIND_SYS_NAME}_FOUND FALSE)
  ELSE()
    SET(${SNAP_FIND_SYS_NAME}_FOUND TRUE)   
  ENDIF()
  
  #MESSAGE(FATAL_ERROR "${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS: ${${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS}\n${SNAP_FIND_SYS_NAME}_LIBRARIES: ${${SNAP_FIND_SYS_NAME}_LIBRARIES}")
  
  MARK_AS_ADVANCED(${SNAP_FIND_SYS_NAME}_INCLUDE_DIRS ${SNAP_FIND_SYS_NAME}_LIBRARIES)
ENDMACRO()
