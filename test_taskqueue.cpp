#include "gtest/gtest.h"
#include "glog/logging.h"
#include "taskqueue.hpp"
#include "boost/functional/hash.hpp"
#include "boost/foreach.hpp"
#include "snap/packages/progress/progress.hpp"
#include <stdlib.h>

using namespace progress;

std::size_t HashString(const std::string& data){
  boost::hash<std::string> string_hasher;
  return string_hasher(data);
}

std::string GenerateRandomPassword(int length){
  std::string chars(
      "abcdefghijklmnopqrstuvwxyz"
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      "1234567890"
      "!@#$%^&*()"
      "`~-_=+[{]{\\|;:'\",<.>/? ");

  std::string password;
  for (int i = 0; i < length; ++i) {
    password.push_back(chars[rand() % chars.size()]);
  }
  return password;
}

struct HashStringTaskResult{
  int i;
  std::size_t hash;
};

struct HashStringTask {
  typedef HashStringTaskResult result_type;
  HashStringTask(int i, std::string* data) :
    i_(i),
    data_(data) {
  }

  result_type operator()() {
    result_type result;
    result.i = i_;
    boost::hash<std::string> string_hasher;
    result.hash = string_hasher(*data_);
    return result;
  }

  int i_;
  std::string* data_;
};

TEST(TaskQueue, simple) {

  // Generate lots of input data
  int num_passwords = 100000;
  LOG(INFO) << "Generating " << num_passwords << " random passwords...";
  std::vector<std::string> passwords(num_passwords);
  ProgressBar<int> generate_progress(num_passwords);
  for (int i=0; i < num_passwords; ++i){
    passwords[i] = GenerateRandomPassword(10000);
    generate_progress.Update(i);
  }

  // Feed the work to the task queue's thread pool
  typedef TaskQueue<HashStringTask> MyTaskQueue;
  MyTaskQueue queue;
  LOG(INFO) << "Hashing passwords in thread pool...";
  LOG(INFO) << "TIP: Run top to watch CPU usage go up to 100%...";
  std::vector<HashStringTaskResult> results;
  ProgressBar<int> hash_progress(num_passwords);
  for (int i=0; i < passwords.size(); ++i){
    HashStringTask task(i, &passwords[i]);
    queue.QueueTask(task);
    while (queue.TasksCompleted()){
      HashStringTaskResult result = queue.GetCompletedTaskResult();
      results.push_back(result);
    }
    hash_progress.Update(i);
  }

  while (queue.NumPendingTasks()){
    LOG(INFO) << "All tasks submitted, waiting for last tasks to complete...";
    boost::this_thread::sleep(boost::posix_time::milliseconds(10));
  }

  LOG(INFO) << "Validating hashes are correct...";
  ProgressBar<int> validation_progress(num_passwords);
  BOOST_FOREACH(HashStringTaskResult result, results){
    ASSERT_EQ(result.hash, HashString(passwords[result.i]));
    validation_progress.Increment();
  }

}


int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
