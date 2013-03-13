# Multiple-inclusion guard
IF(__MACRO_UTILS_INCLUDED)    
    RETURN()
ENDIF()
SET(__MACRO_UTILS_INCLUDED TRUE)

INCLUDE(CMakeParseArguments)


###############################################################################
# SNAP - General
###############################################################################


MACRO(REQUIRE_NOT_EMPTY)
  # NOTE: must be a macro and not a function because it must access variables
  # from caller's scope  
  FOREACH(varName ${ARGN})            
    IF(NOT ${varName})      
      MESSAGE(FATAL_ERROR "Required parameter is empty: ${varName}")
    ENDIF()
  ENDFOREACH()
ENDMACRO()

# Causes linker to fail if target is missing any symbols (useful for library targets)
# Linking an executable will fail if there are symbols missing, but a library will seem ok until you try to use it.
# This causes the same checking that occurs for an executable to be done for a library. 
MACRO(CHECK_FOR_MISSING_SYMBOLS target)
    #GET_TARGET_PROPERTY(CUR_LINK_FLAGS ${target} LINK_FLAGS)
    #IF (NOT CUR_LINK_FLAGS)
    #    SET(CUR_LINK_FLAGS "")
    #ENDIF()   
    #SET_TARGET_PROPERTIES(${target} PROPERTIES LINK_FLAGS "${CUR_LINK_FLAGS} -Wl,-z,defs")
ENDMACRO()    


FUNCTION(DISPLAY_PACKAGE_STATUS)
  CMAKE_PARSE_ARGUMENTS("" # Default arg prefix is just "_" 
                      "" # Option type arguments
                      "TYPE;URI;" # Single value arguments
                      "MISSING_URIS;" # List valued arguments
                      "${ARGN}" )
  # Make sure required parameters were provided
  REQUIRE_NOT_EMPTY(_TYPE _URI)
  MAKE_FRIENDLY_URI(${_URI} friendly_package_uri)
  IF(_MISSING_URIS)    
    MESSAGE("SKIPPED: ${friendly_package_uri}")
    FOREACH(missing_package_uri ${_MISSING_URIS})
      MESSAGE("* unresolved package: ${missing_package_uri}")
    ENDFOREACH()
  ELSE()
    MESSAGE("     OK: ${friendly_package_uri} (${_TYPE})")
  ENDIF()
ENDFUNCTION()

###############################################################################
# SNAP - Packages
###############################################################################

MACRO(GET_KNOWN_PACKAGES listName modulePaths)
  FOREACH(path ${modulePaths})    
    FILE(GLOB files "${path}Find*.cmake")
    FOREACH(file ${files})
       STRING(REGEX REPLACE ".+Find(.+)\\.cmake" "\\1" str "${file}")
       LIST(APPEND ${listName} ${str})
    ENDFOREACH(file ${files})    
  ENDFOREACH(path ${modulePaths})
ENDMACRO(GET_KNOWN_PACKAGES listName)

MACRO(PRINT_KNOWN_PACKAGES)
  MESSAGE( "Project Tools Custom Packages:")
  SET(modulePaths "${CMAKE_MODULE_PATH}")  
  MESSAGE("From ${modulePaths}")  
  SET(knownPackages "")
  GET_KNOWN_PACKAGES(knownPackages ${modulePaths})
  LIST(SORT knownPackages)    
  SET(packageListString "")
  FOREACH(package ${knownPackages})    
    SET(packageListString "${packageListString} ${package}")   
  ENDFOREACH(package ${knownPackages})
  MESSAGE(${packageListString})
  MESSAGE( "")
  
  MESSAGE("CMake Default Packages:")
  SET(modulePaths "${CMAKE_ROOT}/Modules/")
  MESSAGE("From ${modulePaths}")  
  SET(knownPackages "")
  GET_KNOWN_PACKAGES(knownPackages ${modulePaths})
  LIST(SORT knownPackages)    
  
  SET(packageListString "")
  FOREACH(package ${knownPackages})    
    SET(packageListString "${packageListString} ${package}")   
  ENDFOREACH(package ${knownPackages})
  MESSAGE( ${packageListString})
ENDMACRO(PRINT_KNOWN_PACKAGES)

################################################################################
# SNAP - Package URI parsing
################################################################################

SET(PRJ_URI_REGEX "^(PRJ)://([a-zA-Z0-9/-_]+):([a-zA-Z0-9-_]+).+$")
SET(SYS_URI_REGEX "^(SYS)://([a-zA-Z0-9-_]+)$")
SET(VALID_URI_REGEX "^(PRJ|SYS)://(.*)")

#
MACRO(VERIFY_URI_OR_DIE uri)  
  STRING(REGEX MATCH ${VALID_URI_REGEX} found ${uri})
  IF(NOT found)    
    MESSAGE(SEND_ERROR "Valid uris must start with //, PRJ://, or SYS://")
    MESSAGE(FATAL_ERROR "Invalid uri: ${uri}")
  ENDIF()
  
  # verify uri has only one run of multiple slashes (e.g. catch the case where the path has a run of more than one /)
  string(REGEX MATCHALL "(//+)" multi_slash_match_list ${uri})
  LIST( LENGTH multi_slash_match_list num_multi_slashes )
  
  IF (${num_multi_slashes} GREATER 1)    
    MESSAGE(SEND_ERROR "Path portion of uris must not contain multiple slashes: ${uri}")
    MESSAGE(FATAL_ERROR "Invalid uri: ${uri}")
  ENDIF() 
      
ENDMACRO()

#
MACRO(PARSE_URI_SCHEME uri uri_scheme)  
  STRING(REGEX REPLACE ${VALID_URI_REGEX} "\\1" ${uri_scheme} ${uri})     
ENDMACRO()

#
MACRO(MAKE_FRIENDLY_URI uri friendly_uri)
  STRING(REGEX REPLACE ${VALID_URI_REGEX} "//\\2" ${friendly_uri} ${uri})     
ENDMACRO()

#
MACRO(PARSE_URI uri scheme path basename)
  VERIFY_URI_OR_DIE(${uri})  
  PARSE_URI_SCHEME(${uri} uri_scheme)  
  IF ("${uri_scheme}" STREQUAL "PRJ")
    STRING(REGEX REPLACE ${PRJ_URI_REGEX} "\\1;\\2;\\3" uri_parse_list ${uri})
    LIST(LENGTH uri_parse_list num_matches)
    IF (NOT num_matches EQUAL 3)
        MESSAGE("uri_parse_list: ${uri_parse_list}")
        MESSAGE(FATAL_ERROR "REGEX parsing failed!")
    ENDIF()
    
    LIST(GET uri_parse_list 0 ${scheme})
    LIST(GET uri_parse_list 1 ${path})
    LIST(GET uri_parse_list 2 ${basename})
  ELSEIF ("${uri_scheme}" STREQUAL "SYS")
    STRING(REGEX REPLACE ${SYS_URI_REGEX} "\\1;\\2" uri_parse_list ${uri})
    
    LIST(LENGTH uri_parse_list num_matches)
    IF (NOT num_matches EQUAL 2)
        MESSAGE("uri_parse_list: ${uri_parse_list}")
        MESSAGE(FATAL_ERROR "REGEX parsing failed!")
    ENDIF()
       
    LIST(GET uri_parse_list 0 ${scheme})
    LIST(GET uri_parse_list 1 ${basename})  
  ELSE()
    MESSAGE(FATAL_ERROR "unexpected: ${uri_scheme}")
  ENDIF()    
ENDMACRO()


# Convert a package uri into a string that can be used as a cmake target name
MACRO(TO_CANONICAL_URI in_uri out_uri )
  # Handle elliding the PRJ: prefix (expand // to PRJ://)
  STRING(REGEX REPLACE "^//(.*)" "PRJ://\\1" ${out_uri} ${in_uri})    
  
  # TODO(kheath): Handle optional elliding of target name when same as target parent dir
  # Check if a target was specified with : and expand if not  
  VERIFY_URI_OR_DIE(${${out_uri}})
ENDMACRO()

MACRO(TO_CANONICAL_URIS in_uris out_uris)  
  FOREACH(uri ${in_uris})      
    TO_CANONICAL_URI(${uri} cannonical_uri)    
    LIST(APPEND ${out_uris} ${cannonical_uri})        
  ENDFOREACH()
ENDMACRO()

# Expands the basename of the package to the full uri by prepending path 
# to local project root
MACRO(PACKAGE_BASENAME_TO_URI package_name uri)
    STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" project_relative_package_path ${CMAKE_CURRENT_SOURCE_DIR})    
    SET(${uri} "PRJ://${project_relative_package_path}:${package_name}")
ENDMACRO()    

# Convert a package uri into a string that can be used as a cmake target name
MACRO(URI_TO_TARGET_NAME uri target_name )    
    TO_CANONICAL_URI(${uri} tmp)
    STRING(REPLACE "://" "-" tmp ${tmp})    
    STRING(REPLACE "/" "-" tmp ${tmp})
    STRING(REPLACE ":" "-" tmp ${tmp})    
    SET(${target_name} ${tmp})    
ENDMACRO()

################################################################################
# SNAP - Python
################################################################################

MACRO(CREATE_PYTHON_INIT_FILES)
    #MESSAGE("CREATE_PYTHON_INIT_FILES")
    SET(cur_dir ${CMAKE_CURRENT_BINARY_DIR})        
    SET(done 0)
    WHILE(NOT done)
      IF(NOT EXISTS "${cur_dir}/__init__.py")      
          CONFIGURE_FILE("${cmakesnap_DIR}/internal/__init__.py.in" "${cur_dir}/__init__.py")
      ELSE()
          #MESSAGE("cur dir already has an __init__.py file.. no need for a default one: ${cur_dir}")
      ENDIF()      
      STRING(REGEX REPLACE "${CMAKE_BINARY_DIR}/(.*)" "\\1" dest_dir ${cur_dir})
      INSTALL(FILES "${cur_dir}/__init__.py" DESTINATION ${dest_dir} )
      GET_FILENAME_COMPONENT(new_dir ${cur_dir} PATH)
      #MESSAGE("cur_dir: ${cur_dir}")
      SET(cur_dir ${new_dir})
      STRING(COMPARE EQUAL ${cur_dir} ${CMAKE_BINARY_DIR} done)  
    ENDWHILE()        
ENDMACRO()

# Note: You must place the files arg in quotes when you call this cmd SYMLINK_TO_BINARY_DIR("${my_files_list}")
# TODO: add arg check to make sure above error doesn't happen accidently
MACRO(SYMLINK_TO_BINARY_DIR files)    
    FOREACH(file ${files})        
        SET (src_file_path ${CMAKE_CURRENT_SOURCE_DIR}/${file})
        SET (dst_file_path ${CMAKE_CURRENT_BINARY_DIR}/${file})
        IF(EXISTS ${src_file_path})
          EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E create_symlink ${src_file_path} ${dst_file_path})
        ELSE()
          MESSAGE(FATAL_ERROR "Missing source file: ${src_file_path}")
        ENDIF()
    ENDFOREACH(file)
ENDMACRO()


#Example usage 
# LOCAL_PATHS_TO_ABSOLUTE_PATHS(INPUT_PATHS ${input_paths} FILE_PATHS files DIR_PATHS dirs)
FUNCTION(LOCAL_PATHS_TO_ABSOLUTE_PATHS)
  
  CMAKE_PARSE_ARGUMENTS("" # Default arg prefix is just "_" 
                      "" # Option type arguments
                      "FILE_PATHS;DIR_PATHS" # Single value arguments
                      "INPUT_PATHS;" # List valued arguments
                      "${ARGN}" )
  # Make sure required parameters were provided
  REQUIRE_NOT_EMPTY(_INPUT_PATHS _FILE_PATHS _DIR_PATHS)

  SET(file_paths "")
  SET(dir_paths "")
  FOREACH(path ${_INPUT_PATHS})   
    IF(NOT IS_ABSOLUTE ${path})
      SET (path ${CMAKE_CURRENT_SOURCE_DIR}/${path})
    ENDIF()
    
    IF(NOT EXISTS ${path})
      MESSAGE(FATAL_ERROR "specified path doesn't exist: ${path}")
    ENDIF()
    
    #MESSAGE(STATUS "******************* path: ${path}") 
    IF(IS_DIRECTORY "${path}")
      LIST(APPEND dir_paths ${path})     
    ELSE()
      LIST(APPEND file_paths ${path})
    ENDIF()
  ENDFOREACH()
  
  # Copy to output variables (notice PARENT_SCOPE required when using function instead of macro)  
  set(${_FILE_PATHS} ${file_paths} PARENT_SCOPE)
  set(${_DIR_PATHS} ${dir_paths} PARENT_SCOPE)  
ENDFUNCTION()



