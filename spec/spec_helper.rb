$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'mspack'
require 'fileutils'
require 'byebug'

TEST_FILE_1 = File.expand_path("#{__dir__}/chm_files/test1.chm")

TEST_FILE_2 = File.expand_path("#{__dir__}/chm_files/test2.chm")

COMPRESSED_FILES_1 = [
  '/#IDXHDR',
  '/#ITBITS',
  '/#STRINGS',
  '/#SYSTEM',
  '/#TOPICS',
  '/#URLSTR',
  '/#URLTBL',
  '/$FIftiMain',
  '/$OBJINST',
  '/$WWAssociativeLinks/Property',
  '/$WWKeywordLinks/Property',
  '/test.html'
]

COMPRESSED_FILES_2 = [
  '/#IDXHDR',
  '/#ITBITS',
  '/#STRINGS',
  '/#SYSTEM',
  '/#TOPICS',
  '/#URLSTR',
  '/#URLTBL',
  '/$FIftiMain',
  '/$OBJINST',
  '/$WWAssociativeLinks/Property',
  '/$WWKeywordLinks/Property',
  '/test2.html'
]

TEMP_DIR_UNEXPANDED = "#{__dir__}/../tmp/extraction_output"

TEMP_DIR = File.expand_path(TEMP_DIR_UNEXPANDED)
