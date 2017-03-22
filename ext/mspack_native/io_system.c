#include "io_system.h"

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

struct io_file {
  FILE *file;
};

struct mspack_file *
io_open(struct mspack_system *self, const char *filename, int mode) {
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
  file->file = fopen(filename, modeStr);

  if (file->file) {
    return (struct mspack_file *)file;
  }
  else {
    free(file);
    return NULL;
  }
}

void io_close(struct mspack_file *file) {
  fclose(((struct io_file *)file)->file);
  free(file);
}

int io_read(struct mspack_file *file, void *buffer, int bytes) {
  return (int)fread(buffer, 1, bytes, ((struct io_file *)file)->file);
}

int io_write(struct mspack_file *file, void *buffer, int bytes) {
  return (int)fwrite(buffer, 1, bytes, ((struct io_file *)file)->file);
}

int io_seek(struct mspack_file *file, off_t offset, int mode) {
  return fseek(((struct io_file *)file)->file, offset, mode);
}

off_t io_tell(struct mspack_file *file) {
  return ftell(((struct io_file *)file)->file);
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
