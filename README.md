# MspackRb

### A simple Ruby native extension gem wrapper for [libmspack](https://www.cabextract.org.uk/libmspack/)

Requires libmspack to be installed, and currently, only CHM extraction has been
implemented.

The gem is available over at [https://rubygems.org/gems/mspack_rb](https://rubygems.org/gems/mspack_rb).

### Usage:
    require 'mspack'

    # Extract all files to disk
    dcom = Mspack::ChmDecompressor.new
    header = dcom.open('path/to/a/chm/file')
    header.each_file { |file| dcom.extract(file, out_path) }
    dcom.close(header)

    # Extract a specific file by name
    fast_open_header = dcom.fast_open('path/to/a/chm/file')
    file = dcom.fast_find(fast_open_header, '/index.html')
    dcom.extract(file) unless file.nil?

    # check last error
    p 'w00t' if dcom.last_error == :ok
