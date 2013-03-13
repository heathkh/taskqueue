# Defines a macro to make it easy to build a package of files that is not stored
# in the source tree but fetched and expanded in bin tree when not there

MACRO(REMOTE_RESOURCES)
  SET(argList "${ARGN}")
  CMAKE_PARSE_ARGUMENTS("" # Arg prefix is just "_" 
                      "" # Option type arguments
                      "NAME;URL;MD5;" # Single value arguments
                      "" # List valued arguments 
                      ${argList} )
  REQUIRE_NOT_EMPTY(_NAME _URL _MD5)

  IF(_UNPARSED_ARGUMENTS)
    MESSAGE(FATAL_ERROR "unexpected arguments: ${_UNPARSED_ARGUMENTS}")
  ENDIF()

  PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
  URI_TO_TARGET_NAME(${target_uri} target)

  SET(REMOTE_RESOURCES_READY_FILE "${CMAKE_CURRENT_BINARY_DIR}/${_MD5}.ready") 
  SET(REMOTE_RESOURCES_CACHE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${_MD5}.cache")
    
  # check if bin dir has the tarball
  IF(NOT EXISTS REMOTE_RESOURCES_READY_FILE) 
    # if not yet downloaded download the tarball and verify md5 is correct
    FILE(DOWNLOAD ${_URL} ${REMOTE_RESOURCES_CACHE_FILE} 
         SHOW_PROGRESS
         EXPECTED_MD5 ${_MD5}) 
  
    IF (NOT EXISTS ${REMOTE_RESOURCES_CACHE_FILE})
      MESSAGE(FATAL_ERROR "Download failed for: ${_URL}")
    ENDIF()
    
    # expand tarball to binary directory
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xzf ${REMOTE_RESOURCES_CACHE_FILE}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
      RESULT_VARIABLE untar_status
    )
    
    IF(${untar_status} EQUAL 0)
      file(WRITE ${REMOTE_RESOURCES_READY_FILE} "OK" )
    ELSE()
      MESSAGE("Failed to untar file ${REMOTE_RESOURCES_CACHE_FILE}.  Error: ${untar_status}")
    ENDIF()
    
  ENDIF()  

  
  #STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
  #INSTALL(FILES ${_FILES} DESTINATION ${dest_dir})
        
  DISPLAY_PACKAGE_STATUS(
    TYPE "REMOTE RESOURCES"
    URI ${target_uri}
    MISSING_URIS ""
  )    
ENDMACRO()










