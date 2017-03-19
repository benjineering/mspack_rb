#include "mspack_native.h"
#include "chm_decompressor.h"
#include "chm_decompressor_file.h"
#include "chm_decompressor_header.h"

#include <mspack.h>

VALUE Mspack = Qnil;
VALUE ChmDecom = Qnil;
VALUE ChmDHeader = Qnil;
VALUE ChmDFile = Qnil;

VALUE mspack_test() {
  int result;
  MSPACK_SYS_SELFTEST(result);
  return result == MSPACK_ERR_OK ? Qtrue : Qfalse;
}

void Init_mspack_native() {
  Mspack = rb_define_module("Mspack");
  rb_define_singleton_method(Mspack, "test", mspack_test, 0);

  Init_chm_decompressor();
  Init_chm_decompressor_header();
  Init_chm_decompressor_file();
}
