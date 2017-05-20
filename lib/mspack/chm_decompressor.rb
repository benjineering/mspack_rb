require 'fileutils'

module Mspack
  class ChmDecompressor
    DEFAULT_BUFFER_SIZE = 4096.freeze

    # Expects a ChmDecompressor::File and either a string, or a fixnum if a block
    # is given.
    #
    # If no block is given, it calls Mspack.ensure_path and extracts file,
    # returning the absolute file path.
    #
    # If a block is given, chunks of data are yielded with a maximum size given 
    # by the dir_or_buffer_size param. Buffer_size must be a multiple of 
    # DEFAULT_BUFFER_SIZE.
    def extract(file, dir_or_buffer_size = DEFAULT_BUFFER_SIZE)

      if block_given?
        buffer_size = dir_or_buffer_size

        if (buffer_size.fdiv(DEFAULT_BUFFER_SIZE).modulo(1) != 0)
          raise ArgumentError, 
            'Buffer_size must be a multiple of DEFAULT_BUFFER_SIZE'
        end

        a = 0
        b = 0
        did_yield = false
        buffer = "\0" * buffer_size

        extract_to_path(file) do |data|
          did_yield = false
          b = a + data.length - 1
          buffer[a..b] = data

          # full buffer - yield and reset
          if b + 1 == buffer_size 
            yield buffer[0..b]
            did_yield = true
            a = 0

          # last read if it's less than default size
          elsif data.length > 0 && data.length < DEFAULT_BUFFER_SIZE
            yield buffer[0..b]
            did_yield = true
          
          else
            a = b + 1
          end
        end

        # last read happened to be default size
        yield buffer[0..b] if !did_yield && b > 0

      else
        path = Mspack.ensure_path(file.filename, dir_or_buffer_size)
        extract_to_path(file, path)
        return path
      end
    end


    class Header

      # Convenience method for iterating over files.
      # Takes a block and yields files.
      def each_file
        file = files

        while !file.nil?
          yield file
          file = file.next
        end
      end

      # Convenience method for iterating over files.
      # Takes a block and yields files and an index number.
      def each_file_with_index
        index = 0

        each_file do |file|
          yield file, index
          index += 1
        end
      end
    end


    class File
    end
  end
end
