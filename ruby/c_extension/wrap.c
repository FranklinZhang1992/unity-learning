#include "ext/demo.h"
#include "ruby.h"

VALUE
wrap_calculate_something (VALUE self, VALUE aa, VALUE bb)
{
  int a;
  float b;
  double result;

  a = FIX2INT (aa);
  b = (float) NUM2DBL (bb);
  result = calculate_something (a, b);
  return DBL2NUM (result);
}

void Init_wrap ()
{
  rb_define_global_function ("calculate_something", wrap_calculate_something, 2);
}
