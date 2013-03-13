// Copyright (c) 2013 Kyle Heath
// 20130213 - Renamed from ezProgressBar to progress, changed api, fixed bugs

// Copyright (C) 2011,2012 Remik Ziemlinski. See MIT-LICENSE.
//
// CHANGELOG
//
// v0.0.0 20110502 rsz Created.
// V1.0.0 20110522 rsz Extended to show eta with growing bar.
// v2.0.0 20110525 rsz Added time elapsed.
// v2.0.1 20111006 rsz Added default constructor value.

#pragma once

#include <iostream>
#include <stdio.h>
#include <sys/time.h> // for gettimeofday
#include <algorithm> // for std::max
#include <string>
#include <assert.h>

namespace progress {

#define SECONDS_TO_MICROSECONDS 1e6
#define MICROSECONDS_TO_SECONDS 1e-6

// One-line refreshing progress bar inspired by wget that shows ETA (time remaining).
// Example output:
// 90% [##################################################     ] ETA 12d 23h 56s
//
// The display will be updated at most once a second or up to max_refreshes
// times.  This guarantee makes it safe to use a progress bar for large
// operations where console IO on every item would slow computation.
template <typename Count>
class ProgressBar {

public:
  ProgressBar(Count task_complete_count, int max_refreshes = 1000, int max_refresh_per_second = 4) :
  task_complete_count_(task_complete_count),
  count_(0),
  next_refresh_count_(0),
  start_time_us_(0),
  last_refresh_time_us_(0),
  min_refresh_period_us_((1.0/max_refresh_per_second)*SECONDS_TO_MICROSECONDS),
  terminal_width_(80),
  max_refreshes_(max_refreshes) {
    Start();
	}
	
	void Increment(Count count_increment = Count(1)) {
	  assert(count_increment >= 0);
	  count_ += count_increment;
		Update(count_);
	};

	void Update(Count new_count) {
	  if (new_count < next_refresh_count_ || new_count > task_complete_count_){
	    return;
	  }
	  count_ = new_count;
	  next_refresh_count_ = std::min(count_ + refresh_increment_, task_complete_count_);
    RefreshDisplay();
	}

private:
	void Start() {
    start_time_us_ = GetTimeMicroseconds();
    refresh_increment_ = std::max(task_complete_count_/max_refreshes_, Count(1));
    next_refresh_count_ = 0;
    RefreshDisplay();
	}

	long long GetTimeMicroseconds() {
    timeval time;
    gettimeofday(&time, NULL);
    return time.tv_sec * 1000000ll + time.tv_usec;
  }



	std::string PrettyPrintDuration(double duration_seconds) {
	  const int sec_per_day = 86400;
	  const int sec_per_hour = 3600;
	  const int sec_per_min = 60;
	  int remaining_seconds = duration_seconds;
	  int days = remaining_seconds/sec_per_day;
	  remaining_seconds -= days*sec_per_day;
		int hours = remaining_seconds/sec_per_hour;
		remaining_seconds -= hours*sec_per_hour;
		int mins = remaining_seconds/sec_per_min;
		remaining_seconds -= mins*sec_per_min;
		char buf[8];
		std::string out;
		if (days >= 7){
		  out = "> 1 week";
		}
		else{
      if (days) {
        snprintf(buf, sizeof(buf), "%dd ", days);
        out += buf;
      }
      if (hours >= 1) {
        snprintf(buf, sizeof(buf), "%dh ", hours);
        out += buf;
      }
      if (mins >= 1) {
        snprintf(buf, sizeof(buf), "%dm ", mins);
        out += buf;
      }
      snprintf(buf, sizeof(buf), "%ds", remaining_seconds);
      out += buf;
		}
		return out;
	}
	
	// Update the display
	void RefreshDisplay() {
	  long long cur_time_us = GetTimeMicroseconds();
	  // don't allow refresh rate faster than once a second, unless we reach 100%
	  long long time_since_last_refresh_us = cur_time_us - last_refresh_time_us_;
	  if (time_since_last_refresh_us < min_refresh_period_us_ && count_ < task_complete_count_  ){
	    return;
	  }
    last_refresh_time_us_ = cur_time_us;
	  float fraction_done = float(count_)/task_complete_count_;
		char buf[5];
		snprintf(buf, sizeof(buf), "%3.0f%%", fraction_done*100.0);

		// Compute how many tics to display.
		int num_tics_max = terminal_width_ - 27;
		int num_tics = num_tics_max*fraction_done;
		std::string out(buf);
		out.append(" [");
		out.append(num_tics,'#');
		out.append(num_tics_max-num_tics,' ');
		out.append("] ");

		double elapsed_time = (cur_time_us - start_time_us_)*MICROSECONDS_TO_SECONDS;
		bool is_done = (fraction_done >= 1.0);

		if (is_done) {
		  // Print overall time
		  out.append("in ");
			out.append(PrettyPrintDuration(elapsed_time));
		}
		else {
		  // Print estimated remaining time
		  out.append("ETA ");
			if (fraction_done > 0.0){
			  double remaining_time = elapsed_time*(1.0-fraction_done)/fraction_done;
			  out.append(PrettyPrintDuration(remaining_time));
			}
		}

		// Pad with spaces to fill terminal width.
    if (out.size() < terminal_width_){
      out.append(terminal_width_-out.size(),' ');
      out.append("\r");
    }

    if (is_done){
      out.append("\n");
      out.append("\n");
    }

		std::cout << out;
		fflush(stdout);
	}

	Count task_complete_count_;
	Count count_;
	Count next_refresh_count_;
	Count refresh_increment_;
	long long start_time_us_;
	long long last_refresh_time_us_;
	long long min_refresh_period_us_;
	int terminal_width_;
  int max_refreshes_;
};


} // close namespace progress

