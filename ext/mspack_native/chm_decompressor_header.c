#include "chm_decompressor_header.h"
#include "chm_decompressor_file.h"
#include "mspack_native.h"

#include <mspack.h>

VALUE chmd_header_filename(VALUE self) {
  struct mschmd_header *header;
  Data_Get_Struct(self, struct mschmd_header, header);
  return rb_str_new2(header->filename);
}

VALUE chmd_header_files(VALUE self) {
  struct mschmd_header *header;
  Data_Get_Struct(self, struct mschmd_header, header);

  if (!header->files) {
    return Qnil;
  }

  struct chmd_file_wrapper *wrapper = malloc(sizeof(struct chmd_file_wrapper));
  wrapper->is_fast_find = 0;
  wrapper->file = header->files;
  
  return Data_Wrap_Struct(ChmDFile, NULL, chmd_file_free, wrapper);
}

VALUE chmd_header_is_fast_open(VALUE self) {
  return rb_iv_get(self, "is_fast_open");
}

void Init_chm_decompressor_header() {
  ChmDHeader = rb_define_class_under(ChmDecom, "Header", rb_cObject);
  rb_define_method(ChmDHeader, "filename", chmd_header_filename, 0);
  rb_define_method(ChmDHeader, "files", chmd_header_files, 0);
  rb_define_method(ChmDHeader, "fast_open?", chmd_header_is_fast_open, 0);
}
