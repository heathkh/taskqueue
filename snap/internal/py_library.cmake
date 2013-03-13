# Defines a macro to make it easy to build a python library  

MACRO(PY_LIBRARY)    
  SET(argList "${ARGN}")
  CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;" # Single value arguments
                      "SOURCES;DATA;PACKAGES;" # List valued arguments 
                      ${argList} )
  REQUIRE_NOT_EMPTY(_NAME _SOURCES)
  
  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()  
  
  INCLUDE(${cmakesnap_DIR}/internal/py_common.cmake)
  
     
  DISPLAY_PACKAGE_STATUS(
    TYPE "PY LIB"
    URI ${target_uri}
    MISSING_URIS ${missing_package_uris}
  )
ENDMACRO(PY_LIBRARY)










