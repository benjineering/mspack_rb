#include "chm_decompressor_file.h"
#include "mspack_native.h"

#include <mspack.h>

VALUE chmd_file_filename(VALUE self) {
  struct mschmd_file *file;
  Data_Get_Struct(self, struct mschmd_file, file);

  if (!file->filename) {
    return Qnil;
  }

  return rb_str_new2(file->filename);
}

VALUE chmd_file_next(VALUE self) {
  struct mschmd_file *file;
  Data_Get_Struct(self, struct mschmd_file, file);  
  struct mschmd_file *next = file->next;

  if (!next) {
    return Qnil;
  }

  VALUE nextObj = Data_Wrap_Struct(ChmDFile, NULL, NULL, next);
  rb_iv_set(nextObj, "is_fast_find", Qfalse);
  return nextObj;
}

VALUE chmd_file_is_fast_find(VALUE self) {
  return rb_iv_get(self, "is_fast_find");
}

void Init_chm_decompressor_file() {
  ChmDFile = rb_define_class_under(ChmDecom, "File", rb_cObject);
  rb_define_method(ChmDFile, "filename", chmd_file_filename, 0);
  rb_define_method(ChmDFile, "next", chmd_file_next, 0);
  rb_define_method(ChmDFile, "fast_find?", chmd_file_is_fast_find, 0);
}
