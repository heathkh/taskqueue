# Defines a macro to make it easy to build a library
#

FUNCTION(CPP_LIBRARY)
  SET(argList "${ARGN}")
  
  CMAKE_PARSE_ARGUMENTS("" # Default arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;LIB_TYPE;SWIG_PY" # Single value arguments
                      "SOURCES;HEADERS;DATA;PACKAGES;" # List valued arguments
                      ${argList} )

  # Make sure required parameters were provided
  REQUIRE_NOT_EMPTY(_NAME _LIB_TYPE)
  
  # Ensure no unexpected parameters were provided
  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()
  
  # Verify parameters are valid  
  IF(_LIB_TYPE)
    STRING(COMPARE EQUAL ${_LIB_TYPE} STATIC BUILD_STATIC_LIB)
    STRING(COMPARE EQUAL ${_LIB_TYPE} SHARED BUILD_SHARED_LIB)
    STRING(COMPARE EQUAL ${_LIB_TYPE} STATIC_AND_SHARED BUILD_STATIC_AND_SHARED_LIB)
    STRING(COMPARE EQUAL ${_LIB_TYPE} HEADER BUILD_HEADER_LIB)
    IF(NOT BUILD_STATIC_LIB AND NOT BUILD_SHARED_LIB AND NOT BUILD_STATIC_AND_SHARED_LIB AND NOT BUILD_HEADER_LIB)
      MESSAGE(FATAL_ERROR "_LIB_TYPE must be one of: STATIC, SHARED, STATIC_AND_SHARED, HEADER")
    ENDIF()
  ELSE()
    MESSAGE(FATAL_ERROR "_LIB_TYPE must be one of: STATIC, SHARED, STATIC_AND_SHARED, HEADER")
  ENDIF()      
  
  IF(BUILD_HEADER_LIB)
    # Ensure HEADER libraries don't also try to give SOURCES
    IF(_SOURCES)    
      MESSAGE(FATAL_ERROR "_LIB_TYPE HEADER is for header only libraries, but you provided source files.")
    ENDIF()  
  ELSE()
    # Ensure non HEADER only libraries do give SOURCES
    IF(NOT _SOURCES)
      MESSAGE(FATAL_ERROR "If you have no _SOURCES files and intended to make a header only library, use _LIB_TYPE 'HEADER' instead of '${_LIB_TYPE}'.")
    ENDIF()
  ENDIF()
    
  IF(_SWIG_PY AND BUILD_STATIC_LIB)
    MESSAGE(FATAL_ERROR "You requested python bindings for a STATIC lib... This is not possible.  Please switch to STATIC_AND_SHARED.")     
  ENDIF()
  
  INCLUDE(${cmakesnap_DIR}/internal/cpp_common.cmake)
  
  # Create target (only if it has _SOURCES, otherwise we have a header only lib)
  IF (BUILD_STATIC_AND_SHARED_LIB)
    # Make recusive calls for each type
    CPP_LIBRARY(
      NAME     ${_NAME}  
      SOURCES  ${_SOURCES}      
      HEADERS  ${_HEADERS}      
      PACKAGES ${_PACKAGES}
      DATA     ${_DATA}
      LIB_TYPE STATIC
    )

    CPP_LIBRARY(
      NAME     ${_NAME}
      SOURCES  ${_SOURCES}      
      HEADERS  ${_HEADERS}      
      PACKAGES ${_PACKAGES}
      DATA     ${_DATA}
      LIB_TYPE SHARED
      SWIG_PY  ${_SWIG_PY}
    )      
  ELSE()
    # If we are here we are building a lib of type STATIC, SHARED, or HEADER
    INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR} ${required_includes})
    GET_DIRECTORY_PROPERTY(CUR_INCLUDE INCLUDE_DIRECTORIES)  
    IF(NOT BUILD_HEADER_LIB)
      IF(BUILD_STATIC_LIB)       
        SET(target_output "${_NAME}")
        ADD_LIBRARY(${target} STATIC ${_HEADERS} ${_SOURCES})        
        set_target_properties(${target} PROPERTIES COMPILE_FLAGS "-fPIC") # -fPIC required for x86_64 static libs            
      ELSEIF(BUILD_SHARED_LIB)                       
        SET(target "${target}-shared")
        SET(target_output "${_NAME}-shared")
        ADD_LIBRARY(${target} SHARED ${_HEADERS} ${_SOURCES})        
        #MESSAGE(FATAL_ERROR "_SWIG_PY: ${_SWIG_PY}")
        IF(_SWIG_PY)
          SET(wrap_package_uri "${target_uri}-shared") 
          SWIG_PYTHON(NAME   py_${_NAME}
                      SOURCE ${_SWIG_PY}
                      WRAP_PACKAGE_URI   ${wrap_package_uri})
        ENDIF()
      ELSE()
        MESSAGE(FATAL_ERROR "this shouldn't happen")
      ENDIF()                   
      SET_TARGET_PROPERTIES("${target}" PROPERTIES OUTPUT_NAME "${target_output}")
      CHECK_FOR_MISSING_SYMBOLS(${target})     
                                
      TARGET_LINK_LIBRARIES(${target} ${required_libraries})
      INCLUDE(${cmakesnap_DIR}/internal/cpp_install_common.cmake)      
    ENDIF()  
        
    # This makes sure CMAKE knows to build all of our dependencies first
    FOREACH(dependency_uri ${_PACKAGES})
      URI_TO_TARGET_NAME(${dependency_uri} dependency_target)
      ADD_DEPENDENCIES(${target} ${dependency_target})
    ENDFOREACH()
        
    #write meta data files to allow the packages to be used easily by other 
    #projects built using the APP_PROJECT or LIB_PROJECT macros
    GET_TARGET_PROPERTY(TARGET_FILE ${target} LOCATION)
    IF(NOT TARGET_FILE)
      SET(TARGET_FILE "")
    ENDIF(NOT TARGET_FILE)
        
    TO_CANONICAL_URIS("${_PACKAGES}" requiredPackages)       
    IF(NOT DEFINED cmakesnap_DIR)
      MESSAGE(FATAL_ERROR "cmakesnap_DIR not defined")
    ENDIF(NOT DEFINED cmakesnap_DIR)    
    CONFIGURE_FILE("${cmakesnap_DIR}/internal/config.cmake.in"
                    ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake @ONLY IMMEDIATE)        
           
    SET("${target}_DIR" ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "Path to package ${target_uri}" FORCE)
    MARK_AS_ADVANCED("${target}_DIR")
    
    # print status update  
    DISPLAY_PACKAGE_STATUS(
      TYPE         "CPP LIB"
      URI          ${target_uri}
      MISSING_URIS ${missing_package_uris}
    )    
  ENDIF()
  
ENDFUNCTION(CPP_LIBRARY)





