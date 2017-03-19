#include "chm_decompressor.h"

#include <mspack.h>

VALUE ChmDecom = Qnil;
VALUE ChmDHeader = Qnil;
VALUE ChmDFile = Qnil;

static inline VALUE error_code_sym(int code) {
  const char *str;

  switch (code) {
  case MSPACK_ERR_OK:
    str = "ok";
    break;
  case MSPACK_ERR_ARGS:
    str = "args";
    break;
  case MSPACK_ERR_OPEN:
    str = "open";
    break;
  case MSPACK_ERR_READ:
    str = "read";
    break;
  case MSPACK_ERR_WRITE:
    str = "write";
    break;
  case  MSPACK_ERR_SEEK:
    str = "seek";
    break;
  case MSPACK_ERR_NOMEMORY:
    str = "no_memory";
    break;
  case MSPACK_ERR_SIGNATURE:
    str = "signature";
    break;
  case MSPACK_ERR_DATAFORMAT:
    str = "data_format";
    break;
  case MSPACK_ERR_CHECKSUM:
    str = "checksum";
    break;
  case MSPACK_ERR_CRUNCH:
    str = "crunch";
    break;
  case MSPACK_ERR_DECRUNCH:
    str = "decrunch";
    break;
  default:
    str = "unknown";
  }

  return ID2SYM(rb_intern(str));
}

void chmd_deallocate(void *decom) {
  mspack_destroy_chm_decompressor(decom);
}

VALUE chmd_allocate(VALUE self) {
  struct mschm_decompressor *decom = mspack_create_chm_decompressor(NULL);
  return Data_Wrap_Struct(self, NULL, chmd_deallocate, decom);
}

VALUE chmd_open(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);

  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);
  struct mschmd_header *header = decom->open(decom, StringValueCStr(path));

  if (!header) {
    return Qnil;
  }

  VALUE headerObj = Data_Wrap_Struct(ChmDHeader, NULL, NULL, header);
  rb_iv_set(headerObj, "is_fast_open", Qfalse);

  return headerObj;
}

VALUE chmd_close(VALUE self, VALUE header) {
  if (!CLASS_OF(header) == ChmDHeader) {
    rb_raise(rb_eTypeError, "Parameter must be a CHM decompression header");
  }

  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_header *headerPtr;
  Data_Get_Struct(header, struct mschmd_header, headerPtr);

  decom->close(decom, headerPtr);
  return Qnil;
}

VALUE chmd_extract_to_path(VALUE self, VALUE file, VALUE outputPath) {
  if (!CLASS_OF(file) == ChmDFile) {
    rb_raise(rb_eTypeError, "First parameter must be a CHM decompression file");
  }

  Check_Type(outputPath, T_STRING);

  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_file *filePtr;
  Data_Get_Struct(file, struct mschmd_file, filePtr);
  const char *pathStr = StringValueCStr(outputPath);

  int result = decom->extract(decom, filePtr, pathStr);
  return result == MSPACK_ERR_OK ? Qtrue : Qfalse;
}

VALUE chmd_last_error(VALUE self) {
  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  int error = decom->last_error(decom);
  return error_code_sym(error);
}

VALUE chmd_fast_open(VALUE self, VALUE path) {
  Check_Type(path, T_STRING);

  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_header *header = decom->fast_open(decom, StringValueCStr(path));

  if (!header) {
    return Qnil;
  }

  VALUE headerObj = Data_Wrap_Struct(ChmDHeader, NULL, NULL, header);
  rb_iv_set(headerObj, "is_fast_open", Qtrue);

  return headerObj;
}

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
  
  return Data_Wrap_Struct(ChmDFile, NULL, NULL, header->files);
}

VALUE chmd_header_is_fast_open(VALUE self) {
  return rb_iv_get(self, "is_fast_open");
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

  if (!next) {
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
  rb_define_method(ChmDecom, "last_error", chmd_last_error, 0);
  rb_define_method(ChmDecom, "fast_open", chmd_fast_open, 1);

  ChmDHeader = rb_define_class_under(ChmDecom, "Header", rb_cObject);
  rb_define_method(ChmDHeader, "filename", chmd_header_filename, 0);
  rb_define_method(ChmDHeader, "files", chmd_header_files, 0);
  rb_define_method(ChmDHeader, "fast_open?", chmd_header_is_fast_open, 0);

  ChmDFile = rb_define_class_under(ChmDecom, "File", rb_cObject);
  rb_define_method(ChmDFile, "filename", chmd_file_filename, 0);
  rb_define_method(ChmDFile, "next", chmd_file_next, 0);
}
