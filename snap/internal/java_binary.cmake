# Defines a macro to make it easy to build a java binary 
MACRO(JAVA_BINARY)
    SET(argList "${ARGN}")
    INCLUDE(${cmakesnap_DIR}/internal/java_common.cmake)
    REQUIRE_NOT_EMPTY(_MAIN_CLASS)
    FIND_PACKAGE(Java)
    INCLUDE(UseJava)
    ADD_EXECUTABLE_JAR(${_NAME} ${_MAIN_CLASS} ${_SOURCES})
  DISPLAY_PACKAGE_STATUS(
    TYPE         "JAVA BIN"
    URI          ${target_uri}
    MISSING_URIS ${missing_package_uris}
  )
ENDMACRO(JAVA_BINARY)






