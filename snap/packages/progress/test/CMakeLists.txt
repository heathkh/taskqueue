CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

CPP_BINARY(
  NAME      test_progress
  SOURCES   test_progress.cpp   
  PACKAGES  //snap/packages/google/glog:glog       
            //snap/packages/progress:progress              
  TEST_SIZE small           
)
