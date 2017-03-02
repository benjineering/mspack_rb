require 'spec_helper'

TEST_FILE_1 = File.expand_path("#{__dir__}/../chm_files/test1.chm")

TEST_FILE_2 = File.expand_path("#{__dir__}/../chm_files/test2.chm")

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

TEMP_DIR = File.expand_path("#{__dir__}/../../tmp/extraction_output")

module Mspack
  describe ChmDecompressor do
    it 'opens a CHM file' do
      dcom = ChmDecompressor.new
      header = dcom.open(TEST_FILE_1)
      expect(header).not_to be nil
    end

    it 'allows creation of multiple instances with multiple files' do
      dcom1 = ChmDecompressor.new
      dcom2 = ChmDecompressor.new
      header1 = dcom1.open(TEST_FILE_1)
      header2 = dcom1.open(TEST_FILE_2)
      expect(header1.filename).to eq(TEST_FILE_1)
      expect(header2.filename).to eq(TEST_FILE_2)
    end

    it 'closes a CHM file' do
      dcom = ChmDecompressor.new
      header = dcom.open(TEST_FILE_1)
      expect(header).not_to be nil      
      expect(dcom.close(header)).to be nil
    end

    it 'extracts files' do
      dcom = ChmDecompressor.new
      header = dcom.open(TEST_FILE_1)
      file = header.files
      expect(file).not_to be nil
      path = "#{TEMP_DIR}/file"

      while !file.nil?
        File.delete(path) if File.exist?(path)
        expect(dcom.extract(file, path)).to be true
        expect(File.exist?(path)).to be true
        file = file.next
      end
      
      File.delete(path) if File.exist?(path)
    end


    describe ChmDecompressor::Header do
      it 'provides easy iteration of files' do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        index = 0

        header.each_file do |file|
          expect(file.filename).to eq(COMPRESSED_FILES_1[index])
          index += 1
        end
      end

      it 'provides easy iteration of files and the current index number' do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        expected_index = 0

        header.each_file_with_index do |file, index|
          expect(file.filename).to eq(COMPRESSED_FILES_1[index])
          expect(index).to eq(expected_index)
          expected_index += 1
        end
      end
    end


    describe ChmDecompressor::File do
      it 'has the expected filename' do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        file = header.files
        expect(file.filename).to eq(COMPRESSED_FILES_1.first)
      end

      it "links to the next file, or nil if it's the last one" do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        file = header.files
        index = 0

        while !file.nil?
          expect(file.filename).to eq(COMPRESSED_FILES_1[index])
          file = file.next
          index += 1
        end
      end
    end
  end
end
