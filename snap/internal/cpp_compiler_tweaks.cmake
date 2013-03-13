# Enable more helpful c++ compiler diagonstic errors and warnings

SET(SNAP_CPP_WARNING_LEVEL 1 CACHE STRING "0 = no warnings, 1 = basic warnings, 2 = basic warnings + error on some warns, 3 = agressive warnings and all warns are errors")
  
#add_definitions(-ferror-limit=10)
  
#No warnings
IF (${SNAP_CPP_WARNING_LEVEL} EQUAL 0)    
#Basic warnings
ELSEIF (${SNAP_CPP_WARNING_LEVEL} EQUAL 1)
  ADD_DEFINITIONS(-Wall)    
  ADD_DEFINITIONS(-Wno-sign-compare)
  ADD_DEFINITIONS(-Werror=return-type)  
  ADD_DEFINITIONS(-Werror=invalid-offsetof)
#Basic warnings and some warnings that are common problems are errors
ELSEIF (${SNAP_CPP_WARNING_LEVEL} EQUAL 2)
  ADD_DEFINITIONS(-Wall)
  ADD_DEFINITIONS(-Wno-sign-compare)
  ADD_DEFINITIONS(-Werror=return-type)    
  ADD_DEFINITIONS(-Werror=invalid-offsetof)
  ADD_DEFINITIONS(-Werror=uninitialized) 
#Agressive warnings and all warnings are errors
ELSEIF (${SNAP_CPP_WARNING_LEVEL} EQUAL 3)
  ADD_DEFINITIONS(-Wall)
  ADD_DEFINITIONS(-Wextra)    
  ADD_DEFINITIONS(-Werror) # all warnings are errors
ENDIF()
   
