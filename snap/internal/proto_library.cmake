# Defines a macro to make it easy to build a library
#
# Required Parameters:
# TARGET name of the protobuf lib
# SOURCE the .proto file
#

function(PROTOBUF_GENERATE_SWIG SRCS)
  SET(SWIG_PROTOBUF_HELPER_EXECUTABLE "create_me_first")
  if(NOT ARGN)
    message(FATAL_ERROR "Error: PROTOBUF_GENERATE_SWIG() called without any proto files")    
  endif(NOT ARGN)
  
  set(${SRCS})  
  foreach(FIL ${ARGN})    
    get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    
    SET(SWIG_HELPER_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.swig")    
    list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.swig")    
    
    # Get a list of proto message names from proto file    
    file(READ "${ABS_FIL}" proto_contents LIMIT 10000000 OFFSET 0)    
    SET(MESSAGE_NAME_REGEX  "message ([^ {]+)")    
    string(REGEX MATCHALL ${MESSAGE_NAME_REGEX}  MATCHES ${proto_contents})    
    SET(MESSAGE_NAMES)
    FOREACH(cur_match ${MATCHES})
        #MESSAGE(STATUS "cur_match: ${cur_match}")
        string(REGEX MATCH ${MESSAGE_NAME_REGEX} IGNORE_ME ${cur_match})    
        #MESSAGE(STATUS "CMAKE_MATCH_0: ${CMAKE_MATCH_0}")
        #MESSAGE(STATUS "CMAKE_MATCH_1: ${CMAKE_MATCH_1}")
        LIST(APPEND MESSAGE_NAMES ${CMAKE_MATCH_1})
    ENDFOREACH()
    
    SET(PACKAGE_NAME_REGEX  "package ([^ ;\n]+)")    
    string(REGEX MATCHALL ${PACKAGE_NAME_REGEX} cur_match ${proto_contents})    
    SET(PACKAGE_NAME ".")
    #MESSAGE(STATUS "cur_match: ${cur_match}")
    IF (cur_match)
        string(REGEX MATCH ${PACKAGE_NAME_REGEX} IGNORE_ME ${cur_match})
        #MESSAGE(STATUS "CMAKE_MATCH_0: ${CMAKE_MATCH_0}")
        #MESSAGE(STATUS "CMAKE_MATCH_1: ${CMAKE_MATCH_1}")
        SET(PACKAGE_NAME "${CMAKE_MATCH_1}.")
    ENDIF()
    
    #MESSAGE(STATUS "PACKAGE_NAME: ${PACKAGE_NAME}")
    
    STRING(REPLACE "." "::" PACKAGE_NAMESPACE ${PACKAGE_NAME})
    
    #MESSAGE(FATAL_ERROR "PACKAGE_NAMESPACE: ${PACKAGE_NAMESPACE}")
    
    # Get the python module name of the proto file    
    file(RELATIVE_PATH module_path ${CMAKE_SOURCE_DIR} "${ABS_FIL}")
    
    get_filename_component(module_path ${module_path} PATH)
    #MESSAGE(STATUS "module_path: ${module_path}") 
    
    STRING(REPLACE "/" "." module_prefix ${module_path})
    SET(MODULE_NAME "${module_prefix}.${FIL_WE}_pb2")
    
    #MESSAGE(STATUS "MODULE_NAME: ${MODULE_NAME}")
    #MESSAGE(STATUS "MESSAGE_NAMES: ${MESSAGE_NAMES}")
    
    SET(TYPEMAP_MACRO_CALLS)
    FOREACH(MESSAGE_NAME ${MESSAGE_NAMES})    
        SET(PROTO_MESSAGE_NAME ${PACKAGE_NAMESPACE}${MESSAGE_NAME})
        SET(PROTO_MESSAGE_PYTHON_NAME ${MESSAGE_NAME})
        SET(PROTO_MESSAGE_PYTHON_MODULE ${MODULE_NAME})
        SET(TYPEMAP_MACRO_CALLS "${TYPEMAP_MACRO_CALLS}\n%proto_typemaps(${PROTO_MESSAGE_NAME},${PROTO_MESSAGE_PYTHON_NAME},${PROTO_MESSAGE_PYTHON_MODULE})")
    ENDFOREACH()     
    configure_file("${cmakesnap_DIR}/internal/protobuf_swig_helper.in" ${SWIG_HELPER_FILE_NAME})
  endforeach()

  set_source_files_properties(${${SRCS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)  
endfunction()

MACRO(PROTO_LIBRARY)
    CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                          "" # Option type arguments
                          "NAME;PROTO" # Single value arguments
                          "PACKAGES;" # List valued arguments
                          ${ARGN})
    
    # Print helpful error messages
    IF(NOT _PROTO)
        MESSAGE(FATAL_ERROR "WARNING: No proto file provided for project ${target}")
    ENDIF()
    
    REQUIRE_NOT_EMPTY(_NAME _PROTO)
    
    IF(_UNPARSED_ARGUMENTS)
      MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
    ENDIF()
    
    # Compute the uri and target name
    PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
    URI_TO_TARGET_NAME(${target_uri} target)
    
    # Compute all package dependencies (transitively)
    LIST(APPEND _PACKAGES "SYS://protobuf")
    COMPUTE_PACKAGE_TRANSITIVE_CLOSURE(${_PACKAGES} missing_package_uris required_package_uris required_libraries required_includes)
    
    # Warn if a dependency is missing.
    IF(missing_package_uris)
      MESSAGE(STATUS "Target SKIPPED: ${target}")
      MESSAGE(STATUS " -> Required packages missing: ${missing_package_uris}")
      RETURN()
    ENDIF()                     
    
    ###################
    #####  C++   ######
    ###################
    FIND_PACKAGE(SYS-protobuf REQUIRED)
    INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})  # Needed for includes relative to project root
    #TODO(kheath): Who uses CUR_INCLUDE?  If not set, everything is broken
    GET_DIRECTORY_PROPERTY(CUR_INCLUDE INCLUDE_DIRECTORIES)
    PROTOBUF_GENERATE_CPP(PROTO_SRCS PROTO_HDRS ${_PROTO})
    
    INCLUDE(${cmakesnap_DIR}/internal/cpp_compiler_tweaks.cmake)
    SET(LIB_TYPE "STATIC")
    # -fPIC required for x86_64 static libs (way want to use as source for a shared lib)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
    ADD_LIBRARY(${target} STATIC ${PROTO_HDRS} ${PROTO_SRCS})   
    
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR} ${required_includes})              
    TARGET_LINK_LIBRARIES(${target} ${required_libraries})    
    CHECK_FOR_MISSING_SYMBOLS(${target})
    SET_TARGET_PROPERTIES(${target} PROPERTIES OUTPUT_NAME ${_NAME})
    GET_TARGET_PROPERTY(TARGET_FILE ${target} LOCATION)
    
    IF(NOT TARGET_FILE)
      SET(TARGET_FILE "")
      MESSAGE(FATAL_ERROR "no target defined!")
    ENDIF()
    
    # install generated files  
    STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
    INSTALL(FILES ${TARGET_FILE} DESTINATION ${dest_dir} )    
    
    SET(requiredPackages ${_PACKAGES})
    CONFIGURE_FILE("${cmakesnap_DIR}/internal/config.cmake.in"
                   ${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake @ONLY IMMEDIATE)                                   
    SET("${target}_DIR" ${CMAKE_CURRENT_BINARY_DIR} CACHE PATH "default path to ${target} lib" FORCE)
    MARK_AS_ADVANCED("${target}_DIR")
    
    ###################
    ##### PYTHON ######
    ###################
    PROTOBUF_GENERATE_PYTHON(PROTO_PYTHON_SRCS ${_PROTO})
    ADD_CUSTOM_TARGET( generate_python_${target}  ALL DEPENDS ${PROTO_PYTHON_SRCS} )
    CREATE_PYTHON_INIT_FILES()    
    # install generated files  
    STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
    INSTALL(FILES ${PROTO_PYTHON_SRCS} DESTINATION ${dest_dir} )
    
    ###################
    ##### SWIG   ######
    ###################
    PROTOBUF_GENERATE_SWIG(PROTO_SWIG_SRCS ${_PROTO})
    ADD_CUSTOM_TARGET( generate_swig_${target}  ALL DEPENDS ${PROTO_SWIG_SRCS} )
   
    ####### DONE ########### 
    DISPLAY_PACKAGE_STATUS(
      TYPE         "PROTO"
      URI          ${target_uri}
      MISSING_URIS ${missing_package_uris}
    )

ENDMACRO(PROTO_LIBRARY)



