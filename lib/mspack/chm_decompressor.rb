require 'fileutils'

module Mspack
  class ChmDecompressor

    # Expects a ChmDecompressor::File and a string.
    # Calls Mspack.ensure_path and extracts file.
    # Returns the absolute file path.
    def extract(file, dir)
      path = Mspack.ensure_path(file.filename, dir)
      extract_to_path(file, path)
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
