PACKAGE_BASENAME_TO_URI(${_NAME} target_uri)
URI_TO_TARGET_NAME(${target_uri} target)

# Compute all package dependencies (transitively)
COMPUTE_PACKAGE_TRANSITIVE_CLOSURE("${_PACKAGES}" missing_package_uris required_package_uris required_libraries required_includes)

SYMLINK_TO_BINARY_DIR("${_DATA}")
SYMLINK_TO_BINARY_DIR("${_SOURCES}")
CREATE_PYTHON_INIT_FILES()
STRING(REGEX REPLACE "${CMAKE_SOURCE_DIR}/(.*)" "\\1" dest_dir ${CMAKE_CURRENT_SOURCE_DIR})
INSTALL(FILES ${_DATA} DESTINATION ${dest_dir})

# Allow installing directories recursively for now... Simplifes importing
# large python projects with many modules. 
LOCAL_PATHS_TO_ABSOLUTE_PATHS(INPUT_PATHS ${_SOURCES} FILE_PATHS source_files DIR_PATHS source_dirs)
INSTALL(FILES ${source_files} DESTINATION ${dest_dir})
INSTALL(DIRECTORY ${source_dirs} DESTINATION ${dest_dir})


