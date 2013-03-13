CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

INCLUDE_DIRECTORIES(${GOOGLE_ROOT}/gtest/include ${GOOGLE_ROOT}/gtest/ )

CPP_LIBRARY(
  NAME      gtest 
  SOURCES 
            src/gtest-all.cc
            src/gtest.cc
            src/gtest-death-test.cc
            src/gtest-filepath.cc
            src/gtest_main.cc
            src/gtest-port.cc
            src/gtest-printers.cc
            src/gtest-test-part.cc
            src/gtest-typed-test.cc
  HEADERS
            include/gtest/gtest-death-test.h
            include/gtest/gtest.h
            include/gtest/gtest-message.h
            include/gtest/gtest-param-test.h
            include/gtest/gtest_pred_impl.h
            include/gtest/gtest-printers.h
            include/gtest/gtest_prod.h
            include/gtest/gtest-spi.h
            include/gtest/gtest-test-part.h
            include/gtest/gtest-typed-test.h
  PACKAGES  SYS://threads            
  LIB_TYPE  STATIC
)
