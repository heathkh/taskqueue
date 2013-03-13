# Multiple-inclusion guard
IF(__CMAKESNAP_INCLUDED)    
  RETURN()
ENDIF()
SET(__CMAKESNAP_INCLUDED TRUE)

# Make sure our modified internal versions of certain modules are found
# instead of the system default ones 
SET(CMAKE_MODULE_PATH "${cmakesnap_DIR}/internal/modules/;${cmakesnap_DIR}/sys/;${CMAKE_MODULE_PATH}")
MARK_AS_ADVANCED(FORCE cmakesnap_DIR)

INCLUDE(${cmakesnap_DIR}/internal/macro_utils.cmake)
INCLUDE(${cmakesnap_DIR}/internal/load_required_packages.cmake)
INCLUDE(${cmakesnap_DIR}/internal/cpp_binary.cmake)
INCLUDE(${cmakesnap_DIR}/internal/cpp_library.cmake)
INCLUDE(${cmakesnap_DIR}/internal/proto_library.cmake)
INCLUDE(${cmakesnap_DIR}/internal/py_swig.cmake)
INCLUDE(${cmakesnap_DIR}/internal/py_binary.cmake)
INCLUDE(${cmakesnap_DIR}/internal/py_library.cmake)
INCLUDE(${cmakesnap_DIR}/internal/java_library.cmake)
INCLUDE(${cmakesnap_DIR}/internal/java_binary.cmake)
INCLUDE(${cmakesnap_DIR}/internal/testing.cmake)
INCLUDE(${cmakesnap_DIR}/internal/sys_package_utils.cmake)
INCLUDE(${cmakesnap_DIR}/internal/local_resources.cmake)
INCLUDE(${cmakesnap_DIR}/internal/remote_resources.cmake)


SET(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")




