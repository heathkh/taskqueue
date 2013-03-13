CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;MAIN_CLASS" # Single value arguments
                      "SOURCES" # List valued arguments # add for tools support: 
                      ${argList} )
REQUIRE_NOT_EMPTY(_NAME _SOURCES)

IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
ENDIF()

PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
URI_TO_TARGET_NAME(${target_uri} target)




