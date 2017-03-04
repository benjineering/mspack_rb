#include "chm_decompressor.h"

#include <mspack.h>

VALUE ChmDecom = Qnil;
VALUE ChmDHeader = Qnil;
VALUE ChmDFile = Qnil;

void chmd_deallocate(void *decom) {
  mspack_destroy_chm_decompressor(decom);
}

VALUE chmd_allocate(VALUE self) {
  struct mschm_decompressor *decom = mspack_create_chm_decompressor(NULL);
  return Data_Wrap_Struct(self, NULL, chmd_deallocate, decom);
}

VALUE chmd_open(VALUE self, VALUE path) {
  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);
  struct mschmd_header *header = decom->open(decom, StringValueCStr(path));

  if (!header) {
    return Qnil;
  }

  VALUE headerObj = rb_obj_alloc(ChmDHeader);
  rb_obj_call_init(headerObj, 0, NULL);
  return Data_Wrap_Struct(ChmDHeader, NULL, NULL, header);
}

VALUE chmd_close(VALUE self, VALUE header) {
  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_header *headerPtr;
  Data_Get_Struct(header, struct mschmd_header, headerPtr);

  decom->close(decom, headerPtr);
  return Qnil;
}

VALUE chmd_extract_to_path(VALUE self, VALUE file, VALUE outputPath) {
  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_file *filePtr;
  Data_Get_Struct(file, struct mschmd_file, filePtr);

  const char *pathStr = StringValueCStr(outputPath);
  return decom->extract(decom, filePtr, pathStr) == MSPACK_ERR_OK ? 
    Qtrue : Qfalse;
}

VALUE chmd_header_filename(VALUE self) {
  struct mschmd_header *header;
  Data_Get_Struct(self, struct mschmd_header, header);
  return rb_str_new2(header->filename);
}

VALUE chmd_header_files(VALUE self) {
  struct mschmd_header *header;
  Data_Get_Struct(self, struct mschmd_header, header);
  
  VALUE fileObj = rb_obj_alloc(ChmDFile);
  rb_obj_call_init(fileObj, 0, NULL);
  return Data_Wrap_Struct(ChmDFile, NULL, NULL, header->files);
}

VALUE chmd_file_filename(VALUE self) {
  struct mschmd_file *file;
  Data_Get_Struct(self, struct mschmd_file, file);
  return rb_str_new2(file->filename);
}

VALUE chmd_file_next(VALUE self) {
  struct mschmd_file *file;
  Data_Get_Struct(self, struct mschmd_file, file);  
  struct mschmd_file *next = file->next;

  if (next == NULL) {
    return Qnil;
  }

  VALUE nextObj = rb_obj_alloc(ChmDFile);
  rb_obj_call_init(nextObj, 0, NULL);
  return Data_Wrap_Struct(ChmDFile, NULL, NULL, next);
}

void Init_chm_decompressor() {
  ChmDecom = rb_define_class_under(Mspack, "ChmDecompressor", rb_cObject);
  rb_define_alloc_func(ChmDecom, chmd_allocate);
  rb_define_method(ChmDecom, "open", chmd_open, 1);
  rb_define_method(ChmDecom, "close", chmd_close, 1);
  rb_define_method(ChmDecom, "extract_to_path", chmd_extract_to_path, 2);

  ChmDHeader = rb_define_class_under(ChmDecom, "Header", rb_cObject);
  rb_define_method(ChmDHeader, "filename", chmd_header_filename, 0);
  rb_define_method(ChmDHeader, "files", chmd_header_files, 0);

  ChmDFile = rb_define_class_under(ChmDecom, "File", rb_cObject);
  rb_define_method(ChmDFile, "filename", chmd_file_filename, 0);
  rb_define_method(ChmDFile, "next", chmd_file_next, 0);
}
