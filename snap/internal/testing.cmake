# Multiple-inclusion guard
IF(__TESTING_INCLUDED)    
    RETURN()
ENDIF()
SET(__TESTING_INCLUDED TRUE)

INCLUDE(${cmakesnap_DIR}/internal/macro_utils.cmake)


MACRO(CHECK_VALID_TEST_SIZE size_param)
    IF (${size_param} STREQUAL "small" OR ${size_param} STREQUAL "medium" OR ${size_param} STREQUAL "large" )
    ELSE() 
        MESSAGE(FATAL_ERROR "Expected size parameter to be small, medium, or large, but you provided: ${size_param}")       
    ENDIF()    
ENDMACRO()

ENABLE_TESTING()

# The default test target will run all tests... 
# Here are additional targets that filter the labels appropriately
ADD_CUSTOM_TARGET(test_small 
                 COMMAND /usr/local/bin/ctest -LE "medium|large"                    
                 WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                 COMMENT "Running all small tests"
                 VERBATIM                 
                 )
                 
ADD_CUSTOM_TARGET(test_medium
                 COMMAND /usr/local/bin/ctest -LE "large"                    
                 WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                 COMMENT "Running all small and mediuim tests"
                 VERBATIM                 
                 )
                 
ADD_CUSTOM_TARGET(test_large
                 COMMAND /usr/local/bin/ctest                    
                 WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                 COMMENT "Running all small, medium, and large tests"
                 VERBATIM                 
                 )                                  
 
FUNCTION(REGISTER_CPP_TEST)
    SET(argList "${ARGN}")    
    CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                          "" # Option type arguments
                          "NAME;SIZE" # Single value arguments
                          "" # List valued arguments 
                          ${argList} )
    REQUIRE_NOT_EMPTY(_NAME _SIZE)
    CHECK_VALID_TEST_SIZE(${_SIZE})
    
    IF(_UNPARSED_ARGUMENTS)
        MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
    ENDIF()
    PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
    URI_TO_TARGET_NAME(${target_uri} target)
    
    SET(test_target_name "${target}")
    ADD_TEST(NAME ${test_target_name} COMMAND ${target})
    SET_TESTS_PROPERTIES(${test_target_name} PROPERTIES LABELS ${_SIZE})
ENDFUNCTION()

FUNCTION(GET_PATH_TO_BINARY)
    SET(argList "${ARGN}")    
    CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                          "" # Option type arguments
                          "SRC_PATH;BIN_PATH" # Single value arguments
                          "" # List valued arguments 
                          ${argList} )
    REQUIRE_NOT_EMPTY(_SRC_PATH _BIN_PATH)
    
    
    STRING(REPLACE "${CMAKE_SOURCE_DIR}" "" rel_path ${_SRC_PATH})
    #MESSAGE(FATAL_ERROR "rel_path: ${rel_path}")   
    SET(${_BIN_PATH} "${CMAKE_BINARY_DIR}${rel_path}" PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(REGISTER_PY_TEST)
    SET(argList "${ARGN}")    
    CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                          "" # Option type arguments
                          "NAME;SIZE" # Single value arguments
                          "" # List valued arguments 
                          ${argList} )
    REQUIRE_NOT_EMPTY(_NAME _SIZE)
    CHECK_VALID_TEST_SIZE(${_SIZE})
    IF(_UNPARSED_ARGUMENTS)
        MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
    ENDIF()

    PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
    URI_TO_TARGET_NAME(${target_uri} target)

    SET(test_target_name "${target}")    
    GET_TARGET_PROPERTY(python_source_list ${target} SOURCES)    
    #MESSAGE(FATAL_ERROR "python_source_list: ${python_source_list}")
    LIST(GET python_source_list 1 main_python_file)
    
    GET_PATH_TO_BINARY(SRC_PATH ${main_python_file} 
                       BIN_PATH bin_main_python_path)
                       
    #MESSAGE(FATAL_ERROR "bin_main_python_path: ${bin_main_python_path}")                       
    
    ADD_TEST(NAME ${test_target_name} COMMAND ${bin_main_python_path} )
    SET_TESTS_PROPERTIES(${test_target_name} PROPERTIES LABELS ${_SIZE})
ENDFUNCTION()
