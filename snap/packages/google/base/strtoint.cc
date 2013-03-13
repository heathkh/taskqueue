// Copyright 2008 Google Inc. All Rights Reserved.
//
// Architecture-neutral plug compatible replacements for strtol() friends.
// See strtoint.h for details on how to use this component.
//

#include <errno.h>
#include "base/port.h"
#include "base/basictypes.h"
#include "base/strtoint.h"

// Replacement strto[u]l functions that have identical overflow and underflow
// characteristics for both ILP-32 and LP-64 platforms, including errno
// preservation for error-free calls.
int32 strto32_adapter(const char *nptr, char **endptr, int base) {
  const int saved_errno = errno;
  errno = 0;
  const long result = strtol(nptr, endptr, base);
  if (errno == ERANGE && result == LONG_MIN) {
    return kint32min;
  } else if (errno == ERANGE && result == LONG_MAX) {
    return kint32max;
  } else if (errno == 0 && result < kint32min) {
    errno = ERANGE;
    return kint32min;
  } else if (errno == 0 && result > kint32max) {
    errno = ERANGE;
    return kint32max;
  }
  if (errno == 0)
    errno = saved_errno;
  return static_cast<int32>(result);
}

uint32 strtou32_adapter(const char *nptr, char **endptr, int base) {
  const int saved_errno = errno;
  errno = 0;
  const unsigned long result = strtoul(nptr, endptr, base);
  if (errno == ERANGE && result == ULONG_MAX) {
    return kuint32max;
  } else if (errno == 0 && result > kuint32max) {
    errno = ERANGE;
    return kuint32max;
  }
  if (errno == 0)
    errno = saved_errno;
  return static_cast<uint32>(result);
}


// ----------------------------------------------------------------------
// ParseLeadingUInt64Value
// ParseLeadingInt64Value
// ParseLeadingHex64Value
//    A simple parser for long long values. Returns the parsed value if a
//    valid integer is found; else returns deflt
//    UInt64 and Int64 cannot handle decimal numbers with leading 0s.
// --------------------------------------------------------------------
uint64 ParseLeadingUInt64Value(const char *str, uint64 deflt) {
  char *error = NULL;
  const uint64 value = strtoull(str, &error, 0);
  return (error == str) ? deflt : value;
}

int64 ParseLeadingInt64Value(const char *str, int64 deflt) {
  char *error = NULL;
  const int64 value = strtoll(str, &error, 0);
  return (error == str) ? deflt : value;
}

uint64 ParseLeadingHex64Value(const char *str, uint64 deflt) {
  char *error = NULL;
  const uint64 value = strtoull(str, &error, 16);
  return (error == str) ? deflt : value;
}

// ----------------------------------------------------------------------
// ParseLeadingDec64Value
// ParseLeadingUDec64Value
//    A simple parser for [u]int64 values. Returns the parsed value
//    if a valid value is found; else returns deflt
//    The string passed in is treated as *10 based*.
//    This can handle strings with leading 0s.
// --------------------------------------------------------------------

int64 ParseLeadingDec64Value(const char *str, int64 deflt) {
  char *error = NULL;
  const int64 value = strtoll(str, &error, 10);
  return (error == str) ? deflt : value;
}

uint64 ParseLeadingUDec64Value(const char *str, uint64 deflt) {
  char *error = NULL;
  const uint64 value = strtoull(str, &error, 10);
  return (error == str) ? deflt : value;
}
