%module py_base

//%include "snap/google/base/base.swig"
%include std_string.i 

%{
#include "snap/google/base/hashutils.h"
%}

%include "snap/google/base/hashutils.h"
