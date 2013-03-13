FIND_SNAP_SYS_PACKAGE(
  NAME                  SYS-maprhdfs
  LIBRARY_NAMES         jvm hdfs MapRClient 
  LIBRARY_SEARCH_PATHS  "/opt/mapr/lib/" 
                        "/opt/mapr/hadoop/hadoop-0.20.2/c++/lib/" 
                        "/usr/lib/jvm/default-java/jre/lib/amd64/server" 
  PATH_TO_A_HEADER      libhdfs/hdfs.h
  INCLUDE_SEARCH_PATHS  /opt/mapr/hadoop/hadoop-0.20.2/src/c++/
)