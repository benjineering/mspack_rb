require 'spec_helper'

TEST_FILE_1 = File.expand_path("#{__dir__}/../chm_files/test1.chm")

TEST_FILE_2 = File.expand_path("#{__dir__}/../chm_files/test2.chm")

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

    describe ChmDecompressor::File do
      it 'has a file name beginning with /' do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        file = header.files
        expect(file.filename).to match(/\/.+/)
      end

      it "links to the next file, or nil if it's the last one" do
        dcom = ChmDecompressor.new
        header = dcom.open(TEST_FILE_1)
        file = header.files
        count = 0

        while !file.nil?
          expect(file.filename).to match(/\/.+/)
          file = file.next
          count += 1
        end

        expect(count).to be > 1
      end
    end
  end
end
