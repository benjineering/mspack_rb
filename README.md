# MspackRb

### A simple Ruby native extension gem wrapper for [libmspack](https://www.cabextract.org.uk/libmspack/)

Requires libmspack to be installed, and currently, only basic CHM 
extraction has been implemented.

The gem is available over at [https://rubygems.org/gems/mspack_rb](https://rubygems.org/gems/mspack_rb).

### Usage:
    require 'mspack'

    OUT_DIR = 'some/output/directory'

    dcom = Mspack::ChmDecompressor.new
    header = dcom.open('path/to/a/chm/file')

    header.each_file do |file|
      out_path = "#{OUT_DIR}/#{file.filename}"
      dcom.extract(file, out_path)
    end

    dcom.close(header)
