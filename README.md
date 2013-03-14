TaskQueue
===================
TaskQueue is a header-only library for executing tasks in parallel with a thread pool built with Boost. 

How to use it
-----

To use it all you need to do is copy "taskqueue.hpp" to your source tree and link against Boost threads and asio libraries.

There are no docs, only a working example for computing a rainbow table to invert hashed passwords using all the cores available on your machine.  Here's a brief snippet as an example... but check the demo for the full details.

```CPP

//Creates a task queue with a pool of 4 worker threads
TaskQueue<HashStringTask> queue(4);

// Adds a task to the work queue.  Call blocks until there is an available thread in the pool.
queue.QueueTask(HashStringTask("string a"));
queue.QueueTask(HashStringTask("string b"));
queue.QueueTask(HashStringTask("string c"));
queue.QueueTask(HashStringTask("string d"));
queue.QueueTask(HashStringTask("string e"));

// Returns the number of tasks that are queued but not yet completed.
int num_pending = queue.NumPendingTasks();

// Returns the number of completed tasks.
int num_complete = queue.NumCompletedTasks();

// Returns true if there are any completed tasks.
bool has_completed_tasks = queue.TasksCompleted();

// Returns the result of a completed task.  
HashStringTaskResult result = queue.GetCompletedTaskResult();

```

How to compile and run demo
-------------------------
1. Get the code
````bash
git clone git://github.com/heathkh/taskqueue.git
````
The repo is large because the demo includes boost for convenience and some unit test libraries for continuous integration testing.

2. If not installed, install tools to compile code (gcc, CMake)
````bash
apt-get install g++ cmake
````   

3. Run the demo script to compile and run the test binary.
````bash
cd taskqueue; chmod +x ./compile_and_run_test.sh; ./compile_and_run_test.sh 
````   

Contact
------
*Author: Kyle Heath (cmakesnap [at] gmail)*  

Current test status: [![Build Status](https://travis-ci.org/heathkh/taskqueue.png)](https://travis-ci.org/heathkh/taskqueue)
