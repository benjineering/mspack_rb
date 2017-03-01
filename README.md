# MspackRb

### A simple Ruby native extension gem wrapper for [libmspack](https://www.cabextract.org.uk/libmspack/)

Requires libmspack to be installed, and currently, only (very) basic CHM 
extraction has been implemented.

The gem is available over at [https://rubygems.org/gems/mspack_rb](https://rubygems.org/gems/mspack_rb).

### Usage:
    require 'mspack_rb'

    dcom = Mspack::ChmDecompressor.new
    header = dcom.open('path/to/a/chm/file')
    file = header.files
    out_dir = 'some/output/directory'

    while !file.nil?
      out_path = "#{out_dir}/#{file.filename}"
      dcom.extract(file, out_path)
      file = file.next
    end
