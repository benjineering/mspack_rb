#include "chm_decompressor.h"
#include "mspack_native.h"
#include "chm_decompressor_header.h"
#include "chm_decompressor_file.h"

#include <mspack.h>

/*
 * utility methods
 */

static inline VALUE _error_code_sym(int code) {
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

static inline VALUE _open(VALUE self, VALUE path, int fast_bool) {
  Check_Type(path, T_STRING);

  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_header *header;

  if (fast_bool) {
    header = decom->fast_open(decom, StringValueCStr(path));
  }
  else {
    header = decom->open(decom, StringValueCStr(path));
  }

  if (!header) {
    return Qnil;
  }

  VALUE headerObj = Data_Wrap_Struct(ChmDHeader, NULL, NULL, header);
  VALUE is_fast_open = fast_bool ? Qtrue : Qfalse;
  rb_iv_set(headerObj, "is_fast_open", is_fast_open);

  return headerObj;
}

/*
 * decompressor
 */

void chmd_deallocate(void *decom) {
  mspack_destroy_chm_decompressor(decom);
}

VALUE chmd_allocate(VALUE self) {
  struct mschm_decompressor *decom = mspack_create_chm_decompressor(NULL);
  return Data_Wrap_Struct(self, NULL, chmd_deallocate, decom);
}

VALUE chmd_open(VALUE self, VALUE path) {
  return _open(self, path, 0);
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
  return _error_code_sym(error);
}

VALUE chmd_fast_open(VALUE self, VALUE path) {
  return _open(self, path, 1);
}

VALUE chmd_fast_find(VALUE self, VALUE header, VALUE filename) {
  struct mschm_decompressor *decom;
  Data_Get_Struct(self, struct mschm_decompressor, decom);

  struct mschmd_header *headerPtr;
  Data_Get_Struct(header, struct mschmd_header, headerPtr);

  const char *filenameStr = StringValueCStr(filename);

  int structSize = sizeof(struct mschmd_file);
  struct mschmd_file *file = malloc(structSize);

  int result = 
    decom->fast_find(decom, headerPtr, filenameStr, file, structSize);

  if (result != MSPACK_ERR_OK || file->length == 0) {
    free(file);
    return Qnil;
  }  

  file->filename = malloc(sizeof(char) * strlen(filenameStr) + 1);
  strcpy(file->filename, filenameStr);

  VALUE fileObj = Data_Wrap_Struct(ChmDFile, NULL, NULL, file);
  rb_iv_set(fileObj, "is_fast_find", Qtrue);
  return fileObj;
}

void Init_chm_decompressor() {
  ChmDecom = rb_define_class_under(Mspack, "ChmDecompressor", rb_cObject);
  rb_define_alloc_func(ChmDecom, chmd_allocate);
  rb_define_method(ChmDecom, "open", chmd_open, 1);
  rb_define_method(ChmDecom, "close", chmd_close, 1);
  rb_define_method(ChmDecom, "extract_to_path", chmd_extract_to_path, 2);
  rb_define_method(ChmDecom, "last_error", chmd_last_error, 0);
  rb_define_method(ChmDecom, "fast_open", chmd_fast_open, 1);
  rb_define_method(ChmDecom, "fast_find", chmd_fast_find, 2);
}
