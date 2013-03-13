# Defines a macro to make it easy to build a python library  

MACRO(LOCAL_RESOURCES)    
  SET(argList "${ARGN}")
  CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME" # Single value arguments
                      "FILES;" # List valued arguments 
                      ${argList} )
  REQUIRE_NOT_EMPTY(_NAME _FILES)

  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()

  PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
  URI_TO_TARGET_NAME(${target_uri} target)

  SYMLINK_TO_BINARY_DIR("${_FILES}")
  
  STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
  INSTALL(FILES ${_FILES} DESTINATION ${dest_dir})
        
  DISPLAY_PACKAGE_STATUS(
    TYPE "LOCAL RESOURCES"
    URI ${target_uri}
    MISSING_URIS ""
  )        
ENDMACRO()










