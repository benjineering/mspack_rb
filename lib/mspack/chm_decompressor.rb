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
    # by the dir_or_buffer_size param. The buffer size must be greater than or
    # equal to DEFAULT_BUFFER_SIZE.
    def extract(file, dir_or_buffer_size = DEFAULT_BUFFER_SIZE)

      if block_given?
        unless dir_or_buffer_size.is_a?(Fixnum)
          raise ArgumentError, 
            'dir_or_buffer_size must be a Fixnum if a block is given'
        end

        if dir_or_buffer_size < DEFAULT_BUFFER_SIZE
          raise ArgumentError, 
            'dir_or_buffer_size must be greater than or equal to '\
            'DEFAULT_BUFFER_SIZE'
        end

        i = 0
        buffer = Array.new(dir_or_buffer_size * 2 - 1, 0)

        extract_to_path(file) do |data|



          yield data
        end

      else
        path = Mspack.ensure_path(file.filename, dir_or_buffer_size)
        extract_to_path(file, path)
      end

      path
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
