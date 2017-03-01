require 'mkmf'

LIB_NAME = 'mspack'

LIB_FUNCTION = 'mspack_version'

HEADER_DIRS = [
  '/usr/local/include',         # homebrew / from source
  RbConfig::CONFIG['includedir'], # ruby install locations
  '/usr/include'                # fallback
]

LIB_DIRS = [
  '/usr/local/lib',             # homebrew / from source
  RbConfig::CONFIG['libdir'],     # ruby install locations
  '/usr/lib'                    # fallback
]

dir_config(LIB_NAME, HEADER_DIRS, LIB_DIRS)

unless find_header("#{LIB_NAME}.h") && find_library(LIB_NAME, LIB_FUNCTION)  
  abort "lib#{LIB_NAME} not found"
end

create_makefile(LIB_NAME)
