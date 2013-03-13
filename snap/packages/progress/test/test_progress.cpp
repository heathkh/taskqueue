#include "snap/packages/google/glog/logging.h"
#include "snap/packages/progress/progress.hpp"
#include <vector>
#include <math.h>

using namespace std;

int main(int argc, char **argv) {

  vector<int> data(100000000);
  vector<int> out_data;

  progress::ProgressBar<size_t> progress(data.size());

  for (int i=0; i < data.size(); ++i){
    int k = log(sqrt(i*i));
    out_data.push_back(k);
    progress.Increment();
  }

  return 0;
}
