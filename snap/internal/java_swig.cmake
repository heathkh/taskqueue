# Defines a macro to make it easy to build SWIG ruby bindings for a library 
#
# Required Parameters:
# TARGET name of the java binding
# SOURCES list of source files
# PACKAGES list of packages directly used by the target
#
# Features:
 
MACRO(JAVA_SWIG)
    MESSAGE(FATAL_ERROR "not yet supported")
    
    SET(requiredParamNames NAME SOURCE WRAP)
    SET(validParamNames ${requiredParamNames} ${optionalParamNames})
    
    SET(argList "${ARGN}")
    
    REQUIRE_PARAMS("${argList}" "${requiredParamNames}")
    
    LOAD_PARAMS(ARGS ${argList} VALID_PARAMS ${validParamNames} PARAMS ${validParamNames})
                                                
    #MESSAGE("arglist: ${argList}")                                            
                                                  
    set(name "${NAME}")
    set(source "${SOURCE}")
    set(packageToWrap "${WRAP}")
    
    GET_FULL_TARGET_NAME(${name} target)
     
    LOAD_REQUIRED_INCLUDES(${target} ${packageToWrap})
    
    IF(NOT ${target}_REQUIRED_INCLUDES_FOUND)
        MESSAGE(STATUS "Target SKIPPED: ${target}")
        IF(${CMAKE_SNAP_HELP_LEVEL} GREATER 0)
        MESSAGE(STATUS " -> Required package missing: ${missingPackges}")
        ENDIF()        
    ELSE()
        MESSAGE(STATUS "Target: ${target}")
    ENDIF()
    
    FIND_PACKAGE(SWIG)
    INCLUDE(${SWIG_USE_FILE})
    
    FIND_PACKAGE(JNI)
    INCLUDE_DIRECTORIES(${JNI_INCLUDE_DIRS})
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
    INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR})
    SET(CMAKE_SWIG_FLAGS "")
    SET_SOURCE_FILES_PROPERTIES(${source} PROPERTIES CPLUSPLUS ON)
    
    SWIG_ADD_MODULE(${name} java ${source})
    
    IF(NOT ${${packageToWrap}_FOUND})
        MESSAGE(ERROR "couldn't find ${packageToWrap}")
    ENDIF()
    
    #MESSAGE("${packageToWrap}_LIBRARIES: ${${packageToWrap}_LIBRARIES}")
    
    SWIG_LINK_LIBRARIES(${name} ${JNI_LIBRARIES} ${${packageToWrap}_LIBRARIES})
    
    #SET_TARGET_PROPERTIES(${target} PROPERTIES OUTPUT_NAME ${name})
    
    #MESSAGE("SWIG_MODULE_${target}_REAL_NAME : ${SWIG_MODULE_${target}_REAL_NAME} ")
    
    # This makes sure CMAKE knows to build all of our dependencies first
    #MESSAGE("name ${SWIG_MODULE_${name}_REAL_NAME}")
    ADD_DEPENDENCIES(${SWIG_MODULE_${name}_REAL_NAME} ${packageToWrap})
    
    #MESSAGE("${packageToWrap}_REQUIRED_PACKAGES: ${${packageToWrap}_REQUIRED_PACKAGES}")
    LOAD_REQUIRED_PACKAGES(${SWIG_MODULE_${name}_REAL_NAME} "${${packageToWrap}_REQUIRED_PACKAGES}")
    
    # This makes sure CMAKE knows to build all of our dependencies first
    FOREACH(dep_package ${${packageToWrap}_REQUIRED_PACKAGES})
        #MESSAGE(STATUS ${dep_package})
        ADD_DEPENDENCIES(${SWIG_MODULE_${name}_REAL_NAME} ${dep_package})
    ENDFOREACH()
    
    
    STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
    
    #INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/${name}.py" DESTINATION ${dest_dir} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    #INSTALL(FILES "${CMAKE_CURRENT_BINARY_DIR}/_${name}.so" DESTINATION ${dest_dir} )
    
    INCLUDE(${cmakesnap_DIR}/cpp_compiler_tweaks.cmake)
    
    MAKE_FRIENDLY_URI(${target_uri} friendly_target_uri)
    MESSAGE(STATUS "${friendly_target_uri} (JAVA SWIG)")

ENDMACRO(JAVA_SWIG)










