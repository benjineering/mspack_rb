#ifndef CHM_DECOMPRESSOR_FILE_H
#define CHM_DECOMPRESSOR_FILE_H

#include <ruby.h>

struct mschmd_file;

struct chmd_file_wrapper {
  int is_fast_find;
  struct mschmd_file *file;
};

void chmd_file_free(void *ptr);

void Init_chm_decompressor_file();

#endif
