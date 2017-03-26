#include "io_system.h"
#include "chm_decompressor.h"

#include <ruby.h>

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#define IO_SYSTEM_MAX_BLOCKS 5

union io_file_value {
  FILE *file;
  VALUE block;
};

struct io_file {
  int is_block;
  union io_file_value value;
};

struct mspack_file *
io_open(struct mspack_system *self, const char *filename, int mode) {
  if (strlen(filename) < 1) {
    return NULL;
  }

  if (filename[0] == '/') {
    const char *modeStr;

    switch (mode) {
    case MSPACK_SYS_OPEN_READ:
      modeStr = "r";
      break;
    case MSPACK_SYS_OPEN_WRITE:
      modeStr = "w";
      break;
    case MSPACK_SYS_OPEN_UPDATE:
      modeStr = "w+";
      break;
    case MSPACK_SYS_OPEN_APPEND:
      modeStr = "a+";
      break;
    default:
      return NULL;
    }

    struct io_file *file = malloc(sizeof(struct io_file));
    file->value.file = fopen(filename, modeStr);
    file->is_block = 0;

    if (file->value.file) {
      return (struct mspack_file *)file;
    }
    else {
      free(file);
      return NULL;
    }
  }

  else {
    VALUE block_id_str = rb_str_new_cstr(filename);
    VALUE block_id = rb_funcall(block_id_str, rb_intern("to_i"), 0);
    VALUE object_space = rb_const_get(rb_cModule, rb_intern("ObjectSpace"));
    VALUE block = rb_funcall(object_space, rb_intern("_id2ref"), 1, block_id);

    if (block == Qnil) {
      return NULL;
    }
    else {
      struct io_file *file = malloc(sizeof(struct io_file));
      file->value.block = block;
      file->is_block = 1;
      return (struct mspack_file *)file;
    }
  }
}

void io_close(struct mspack_file *file) {
  if (!((struct io_file *)file)->is_block) {
    fclose(((struct io_file *)file)->value.file);
  }

  free(file);
}

int io_read(struct mspack_file *file, void *buffer, int bytes) {
  return (int)fread(buffer, 1, bytes, ((struct io_file *)file)->value.file);
}

int io_write(struct mspack_file *file, void *buffer, int bytes) {
  if (!((struct io_file *)file)->is_block) {
    return (int)fwrite(buffer, 1, bytes, ((struct io_file *)file)->value.file);
  }
  else {
    VALUE data = rb_str_new((char *)buffer, bytes);
    VALUE block = ((struct io_file *)file)->value.block;
    rb_funcall(block, rb_intern("yield"), 1, data);
    return bytes;
  }
}

int io_seek(struct mspack_file *file, off_t offset, int mode) {
  return fseek(((struct io_file *)file)->value.file, offset, mode);
}

off_t io_tell(struct mspack_file *file) {
  return ftell(((struct io_file *)file)->value.file);
}

void io_message(struct mspack_file *file, const char *format, ...) {
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  va_end(args);
}

void *io_alloc(struct mspack_system *self, size_t bytes) {
  return malloc(bytes);
}

void io_free(void *ptr) {
  free(ptr);
}

void io_copy(void *src, void *dest, size_t bytes) {
  memcpy(dest, src, bytes);
}

struct mspack_system *io_system() {
  struct mspack_system *system = malloc(sizeof(struct mspack_system));
  system->open = io_open;
  system->close = io_close;
  system->read = io_read;
  system->write = io_write;
  system->seek = io_seek;
  system->tell = io_tell;
  system->message = io_message;
  system->alloc = io_alloc;
  system->free = io_free;
  system->copy = io_copy;
  system->null_ptr = NULL;
  return system;
}
