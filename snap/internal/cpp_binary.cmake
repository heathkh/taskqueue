# Defines a macro to make it easier to build a CPP application. 
#
# Required Parameters:
# NAME name of the executable
# SOURCES list of source files
#
# Optional Parameters:
# HEADERS list of header files
# PACKAGES list of packages directly used by the target
#

# All SNAP packages required by this package will be included automatically and
# any changes to these packages will cause them to be refreshed when this 
# target is built.  This guarentees that any changes made in a package used by
# the application take effect when the application is built.

MACRO(CPP_BINARY)
  SET(argList "${ARGN}")     
  
  CMAKE_PARSE_ARGUMENTS("" # Default arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;TEST_SIZE;" # Single value arguments
                      "SOURCES;HEADERS;DATA;PACKAGES;" # List valued arguments
                      ${argList} )

  # Make sure required parameters were provided
  REQUIRE_NOT_EMPTY(_NAME _SOURCES)

  # Warn if unexpected parameters were provided
  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()
  
  INCLUDE(${cmakesnap_DIR}/internal/cpp_common.cmake)
    
  # Create binary target
  INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR} ${required_includes})
  ADD_EXECUTABLE(${target} ${_HEADERS} ${_SOURCES})
  SET_TARGET_PROPERTIES(${target} PROPERTIES OUTPUT_NAME ${_NAME})                
  TARGET_LINK_LIBRARIES(${target} ${required_libraries})
  INCLUDE(${cmakesnap_DIR}/internal/cpp_install_common.cmake)
    
  # This makes sure CMAKE knows to build all of our dependencies first
  FOREACH(dependency_uri ${_PACKAGES})
    URI_TO_TARGET_NAME(${dependency_uri} dependency_target)
    ADD_DEPENDENCIES(${target} ${dependency_target})
  ENDFOREACH()
    
  # If requested, register as a test
  IF(_TEST_SIZE)
    REGISTER_CPP_TEST(NAME ${_NAME} 
                      SIZE ${_TEST_SIZE})
  ENDIF()
    
  # Print status update
  DISPLAY_PACKAGE_STATUS(
    TYPE         "CPP BIN"
    URI          ${target_uri}
    MISSING_URIS ${missing_package_uris}
  )  
ENDMACRO(CPP_BINARY)










