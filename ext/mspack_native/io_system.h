#ifndef IO_SYSTEM_H
#define IO_SYSTEM_H

#include <mspack.h>
#include <ruby.h>

struct mspack_file *
io_open(struct mspack_system *self, const char *filename, int mode);

void io_close(struct mspack_file *file);

int io_read(struct mspack_file *file, void *buffer, int bytes);

int io_write(struct mspack_file *file, void *buffer, int bytes);

int io_seek(struct mspack_file *file, off_t offset, int mode);

off_t io_tell(struct mspack_file *file);

void io_message(struct mspack_file *file, const char *format, ...);

void *io_alloc(struct mspack_system *self, size_t bytes);

void io_free(void *ptr);

void io_copy(void *src, void *dest, size_t bytes);


struct mspack_system *io_system();

void add_block(VALUE *name, VALUE *block);

#endif
