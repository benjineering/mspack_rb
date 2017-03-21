#include "chm_decompressor_file.h"
#include "mspack_native.h"

#include <mspack.h>

void chmd_file_free(void *ptr) {
  struct chmd_file_wrapper *wrapper = (struct chmd_file_wrapper *)ptr;

  if (wrapper->is_fast_find) {
    if (wrapper->file->filename) {
      free(wrapper->file->filename);
    }

    free(wrapper->file);
  }

  free(ptr);
}

VALUE chmd_file_filename(VALUE self) {
  struct chmd_file_wrapper *wrapper;
  Data_Get_Struct(self, struct chmd_file_wrapper, wrapper);

  if (!wrapper->file->filename) {
    return Qnil;
  }

  return rb_str_new2(wrapper->file->filename);
}

VALUE chmd_file_next(VALUE self) {
  struct chmd_file_wrapper *wrapper;
  Data_Get_Struct(self, struct chmd_file_wrapper, wrapper);
  struct mschmd_file *next = wrapper->file->next;

  if (!next) {
    return Qnil;
  }

  struct chmd_file_wrapper *next_wrapper = 
    malloc(sizeof(struct chmd_file_wrapper));
  next_wrapper->is_fast_find = 0;
  next_wrapper->file = next;

  return Data_Wrap_Struct(ChmDFile, NULL, chmd_file_free, next_wrapper);
}

VALUE chmd_file_is_fast_find(VALUE self) {
  struct chmd_file_wrapper *wrapper;
  Data_Get_Struct(self, struct chmd_file_wrapper, wrapper);
  return wrapper->is_fast_find ? Qtrue : Qfalse;
}

void Init_chm_decompressor_file() {
  ChmDFile = rb_define_class_under(ChmDecom, "File", rb_cObject);
  rb_define_method(ChmDFile, "filename", chmd_file_filename, 0);
  rb_define_method(ChmDFile, "next", chmd_file_next, 0);
  rb_define_method(ChmDFile, "fast_find?", chmd_file_is_fast_find, 0);
}
