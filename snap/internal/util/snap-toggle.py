#!/usr/bin/python
import os
import sys

# To use this command, add the following to your ~/.bashrc file (or similar)
# alias sbs='cd `swap_build_src_path.py`'


# If current path is under the source branch of a cmake SNAP project, try to 
# switch to the corresponding build path.
def main():
  
  # get current dir
  cur_path = os.getcwd()
  
  # walk up the tree, looking for project base dir (contains build dir)
  project_base = None
  in_binary_branch = False
  search_path = cur_path
  while len(search_path) > 1:    
    search_path = os.path.dirname(search_path)    
    test_build_path = '%s/build' % search_path
    if (os.path.exists(test_build_path) and os.path.isdir(test_build_path)):
      project_base = search_path
      
      
  #print 'project_bin_base: %s' % project_bin_base
  
  new_path =  cur_path
  
  if project_base:
    #sys.stderr.write("Detected project_base: %s\n" % project_base)
    
    project_relative_path = cur_path.replace(project_base, '')
    
    #sys.stderr.write("project_relative_path: %s\n" % project_relative_path)
    
    in_binary_branch = True
    if project_relative_path.find('/build') == -1:
      in_binary_branch = False
     
    if in_binary_branch:
      src_path = '%s/%s' % (project_base, project_relative_path.replace('/build/', ''))
      sys.stderr.write("SOURCE tree: %s\n" % src_path)
      new_path = src_path
    else:
      bin_path = '%s/build/%s' % (project_base, project_relative_path)
      sys.stderr.write("BINARY tree: %s\n" % bin_path)
          
      new_path = bin_path
          
   
  else:
    sys.stderr.write("Not in a project tree...\n")
    
  
  print new_path
    
  return 0    

if __name__ == "__main__":        
  main()
    
    
    
    
    
  
