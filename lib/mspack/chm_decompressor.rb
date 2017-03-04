module Mspack
  class ChmDecompressor


    def extract(file, dir)

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
