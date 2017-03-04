require 'spec_helper'

module Mspack

  describe Mspack do
    before(:each) do
      FileUtils.rm_rf("#{TEMP_DIR}/.")
    end

    describe ChmDecompressor do
      describe '#open' do
        it 'returns a header' do
          dcom = ChmDecompressor.new
          header = dcom.open(TEST_FILE_1)
          expect(header).to be_instance_of(ChmDecompressor::Header)
        end

        it 'allows creation of multiple instances with multiple files' do
          dcom1 = ChmDecompressor.new
          dcom2 = ChmDecompressor.new
          header1 = dcom1.open(TEST_FILE_1)
          header2 = dcom1.open(TEST_FILE_2)
          expect(header1.filename).to eq(TEST_FILE_1)
          expect(header2.filename).to eq(TEST_FILE_2)
        end
      end

      describe '#extract_to_path' do
        it 'extracts files' do
          dcom = ChmDecompressor.new
          header = dcom.open(TEST_FILE_1)
          file = header.files
          expect(file).not_to be nil
          path = "#{TEMP_DIR}/file"

          while !file.nil?
            File.delete(path) if File.exist?(path)
            expect(dcom.extract_to_path(file, path)).to be true
            expect(File.exist?(path)).to be true
            file = file.next
          end
        end
      end

      describe '#extract' do
        it 'creates directories and extracts to the path' do
          dcom = ChmDecompressor.new
          header = dcom.open(TEST_FILE_2)

          header.each_file_with_index do |file, index|
            path = dcom.extract(file, TEMP_DIR_UNEXPANDED)
            expect(File.file?(path)).to be true
          end
        end
      end


      describe ChmDecompressor::Header do
        describe '#files' do
          it 'returns the first file' do
            dcom = ChmDecompressor.new
            header = dcom.open(TEST_FILE_2)
            file = header.files
            expect(file).to be_instance_of(ChmDecompressor::File)
            expect(file.filename).to eq(COMPRESSED_FILES_2.first)
          end
        end

        describe '#each_file' do
          it 'takes a block and yields each file' do
            dcom = ChmDecompressor.new
            header = dcom.open(TEST_FILE_1)
            index = 0

            header.each_file do |file|
              expect(file).to be_instance_of(ChmDecompressor::File)
              expect(file.filename).to eq(COMPRESSED_FILES_1[index])
              index += 1
            end
          end
        end

        describe '#each_file_with_index' do
          it 'takes a block and yeilds each file and a 0-based index' do
            dcom = ChmDecompressor.new
            header = dcom.open(TEST_FILE_1)
            expected_index = 0

            header.each_file_with_index do |file, index|
              expect(file).to be_instance_of(ChmDecompressor::File)
              expect(file.filename).to eq(COMPRESSED_FILES_1[index])
              expect(index).to eq(expected_index)
              expected_index += 1
            end
          end
        end
      end


      describe ChmDecompressor::File do
        describe '#filename' do
          it 'returns a string containing an absolute path' do
            dcom = ChmDecompressor.new
            header = dcom.open(TEST_FILE_1)
            file = header.files
            expect(file.filename).to eq(COMPRESSED_FILES_1.first)
          end
        end

        describe '#next' do
          it "returns the next file, or nil if it's the last one" do
            # aka linked list
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
  end
end
