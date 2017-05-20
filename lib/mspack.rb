require "mspack_native"

require 'fileutils'

require 'mspack/chm_decompressor'
require 'mspack/version'

module Mspack

  # Expects two strings.
  # Raises an error if dir is not an existing, writable directory.
  # Expands the dir path, so you can use ~ and . etc.
  # Creates non-existing parent folders for file.filename.
  # Raises an error if the final, expanded path is outside of dir.
  # Returns the expanded file path.
  def self.ensure_path(filename, dir)
    unless filename.is_a?(String) && dir.is_a?(String)
      raise TypeError, 'both parameters must be strings'
    end

    raise PathError, "#{dir} is not a directory" unless ::File.directory?(dir)
    raise PathError, "#{dir} is not writable" unless ::File.writable?(dir)

    expanded_dir = ::File.expand_path(dir)
    path = ::File.expand_path(::File.join(dir, filename))

    unless path.include?(expanded_dir)
      raise PathError, 
        "Expanded path #{path} is not within dir #{expanded_dir}"
    end

    FileUtils.mkdir_p(File.dirname(path))
    path
  end


  class PathError < StandardError
  end
end