#include "io_system.h"
#include "chm_decompressor.h"

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#define IO_SYSTEM_MAX_BLOCKS 5

union io_file_value {
  FILE *file;
  VALUE *block;
};

struct io_file {
  char *name; // only used for block handle
  union io_file_value value;
};

struct io_file *blocks[IO_SYSTEM_MAX_BLOCKS];

inline struct io_file *pop_block(const char *name) {
  for (int i = 0; i < IO_SYSTEM_MAX_BLOCKS - 1; ++i) {
    struct io_file *block = blocks[i];

    if (block) {
      if (strcmp(name, block->name) == 0) {
        blocks[i] = NULL;
        return block;
      }
    }
  }

  return NULL;
}

struct mspack_file *
io_open(struct mspack_system *self, const char *filename, int mode) {
  struct io_file *block = NULL;

  if (mode != MSPACK_SYS_OPEN_READ) {
    block = pop_block(filename);
  }

  if (block) {
    return (struct mspack_file *)block;
  }
  else {
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
    file->name = NULL;

    if (file->value.file) {
      return (struct mspack_file *)file;
    }
    else {
      free(file);
      return NULL;
    }
  }
}

void io_close(struct mspack_file *file) {
  if (!((struct io_file *)file)->name) {
    fclose(((struct io_file *)file)->value.file);
  }
  else {
    free(((struct io_file *)file)->name);
  }

  free(file);
}

int io_read(struct mspack_file *file, void *buffer, int bytes) {
  return (int)fread(buffer, 1, bytes, ((struct io_file *)file)->value.file);
}

int io_write(struct mspack_file *file, void *buffer, int bytes) {
  if (!((struct io_file *)file)->name) {
    return (int)fwrite(buffer, 1, bytes, ((struct io_file *)file)->value.file);
  }
  else {
    VALUE fixnum;
    int *intBuffer = buffer;
    VALUE data = rb_ary_new2(bytes);

    for (int i = 0; i < bytes; ++i) {
      fixnum = LONG2FIX(intBuffer[i]);
      rb_ary_push(data, fixnum);
    }

    VALUE *block;
    block = ((struct io_file *)file)->value.block;
    rb_funcall(*block, rb_intern("yield"), 1, data);
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

// TODO: chuck an error if we're full
void add_block(VALUE *name, VALUE *block) {
  for (int i = 0; i < IO_SYSTEM_MAX_BLOCKS - 1; ++i) {

    if (!blocks[i]) {
      struct io_file *file = malloc(sizeof(struct io_file));
      file->value.block = block;

      const char *nameStr = StringValueCStr(*name);
      file->name = malloc(sizeof(char) * strlen(nameStr) + 1);
      strcpy(file->name, nameStr);

      blocks[i] = file;
    }
  }
}
