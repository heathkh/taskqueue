# Defines a macro to make it easy to build a python application. 

MACRO(PY_BINARY)    
  SET(argList "${ARGN}")
  
  CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;TEST_SIZE;" # Single value arguments
                      "SOURCES;DATA;PACKAGES;" # List valued arguments 
                      ${argList} )
  REQUIRE_NOT_EMPTY(_NAME _SOURCES)

  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()
  
  INCLUDE(${cmakesnap_DIR}/internal/py_common.cmake)    
  ADD_CUSTOM_TARGET(${target} 
                    #[DEPENDS depend depend depend ... ]
                    #[WORKING_DIRECTORY dir]
                    #[COMMENT comment] [VERBATIM]
                    SOURCES ${_SOURCES})   
  
  # If requested, register as a test
  IF(_TEST_SIZE)
    REGISTER_PY_TEST(NAME ${_NAME} 
                     SIZE ${_TEST_SIZE})
  ENDIF()
  
  DISPLAY_PACKAGE_STATUS(
    TYPE "PY BIN"
    URI ${target_uri}
    MISSING_URIS ${missing_package_uris}
  )
      
ENDMACRO(PY_BINARY)










