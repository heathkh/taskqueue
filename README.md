TaskQueue
===================
*Author: Kyle Heath (cmakesnap [at] gmail)*

[![Build Status](https://travis-ci.org/heathkh/taskqueue.png)](https://travis-ci.org/heathkh/taskqueue)

What is TaskQueue
-------------------------------------------------------------------------------

TaskQueue is a header-only library for executing tasks in parallel with a thread pool built with Boost. To use it all you need to do is copy "taskqueue.hpp" to your source tree and link against Boost threads and asio libraries.

The repository includes a demo showing how to use it.  The demo includes many dependencies (glog, gflags, progress) that are not part of TaskQueue, but just useful for the demo.

How to compile and run demo
-------------------------
1. Get the code
````bash
git clone git://github.com/heathkh/taskqueue.git
````

2. If not installed, install tools to compile code (gcc, CMake)
````bash
apt-get install g++ cmake
````   

3. Run the demo script to compile and run the test binary.
````bash
cd taskqueue; chmod +x ./compile_and_run_test.sh; ./compile_and_run_test.sh 
````   
