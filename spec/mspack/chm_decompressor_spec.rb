require 'spec_helper'

module Mspack

  describe Mspack do
    before(:each) do
      FileUtils.rm_rf("#{TEMP_DIR}/.")
    end

    describe ChmDecompressor do
      describe '#open' do
        it "raises a type error if the parameter isn't a string" do
          dcom = ChmDecompressor.new          
          expect { dcom.open(1) }.to raise_error(TypeError)
        end

        it 'returns a header' do
          dcom = ChmDecompressor.new
          header = dcom.open(TEST_FILE_1)
          expect(dcom.last_error).to eq(:ok)

          expect(header).to be_instance_of(ChmDecompressor::Header)
          expect(dcom.last_error).to eq(:ok)
        end

        it 'allows creation of multiple instances with multiple files' do
          dcom1 = ChmDecompressor.new
          dcom2 = ChmDecompressor.new

          header1 = dcom1.open(TEST_FILE_1)
          header2 = dcom2.open(TEST_FILE_2)

          expect(dcom1.last_error).to eq(:ok)
          expect(dcom2.last_error).to eq(:ok)

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

          expect(dcom.last_error).to eq(:ok)
        end

        it 'can take a block instead of a file path' do
          dcom = ChmDecompressor.new
          header = dcom.open(TEST_FILE_1)
          file = header.files

          bytes = []
          dcom.extract_to_path(file) do |data|
            bytes.concat(data)
          end

          expect(bytes.length).to eq(file.length)
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

          expect(dcom.last_error).to eq(:ok)
        end
      end

      describe '#last_error' do
        it 'returns :ok if there is no error' do
          dcom = ChmDecompressor.new
          expect(dcom.last_error).to eq(:ok)
        end

        it 'returns :open if open is called on a non-existant file' do
          dcom = ChmDecompressor.new
          non_existant_file = File.join(TEST_FILE_1, 'nuffin wot is')
          dcom.open(non_existant_file)
          expect(dcom.last_error).to eq(:open)
        end
      end

      describe '#fast_open' do
        it 'returns a header when passed a CHM file path' do
          dcom = ChmDecompressor.new
          header = dcom.fast_open(TEST_FILE_1)

          expect(header).to be_instance_of(Mspack::ChmDecompressor::Header)
          expect(dcom.last_error).to eq(:ok)
        end

        it 'returns true when header#fast_open? is called' do
          dcom = ChmDecompressor.new
          header = dcom.fast_open(TEST_FILE_1)
          expect(header.fast_open?).to be true
        end
      end

      describe '#fast_find' do
        it 'returns an extractable file when passed a header and a filename' do
          dcom = ChmDecompressor.new
          header = dcom.fast_open(TEST_FILE_1)
          file = dcom.fast_find(header, '/#SYSTEM')
          
          expect(dcom.last_error).to eq(:ok)
          expect(file).to be_instance_of(ChmDecompressor::File)

          path = dcom.extract(file, TEMP_DIR_UNEXPANDED)
          expect(File.file?(path)).to be true
        end

        it 'returns nil when the file does not exist' do
          dcom = ChmDecompressor.new
          header = dcom.fast_open(TEST_FILE_1)
          file = dcom.fast_find(header, 'nuffink')

          expect(file).to be nil
        end

        it 'returns true when #fast_find? is called on the returned file' do
          dcom = ChmDecompressor.new
          header = dcom.fast_open(TEST_FILE_1)
          file = dcom.fast_find(header, '/#SYSTEM')

          expect(file.fast_find?).to be true
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

            expect(dcom.last_error).to eq(:ok)
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

            expect(dcom.last_error).to eq(:ok)
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

        describe '#length' do
          it "returns the length of the file, or 0 if opened via fast_find" do
            dcom = ChmDecompressor.new
            header = dcom.open(TEST_FILE_1)
            file = header.files
            expect(file.length).to eq(4096)
          end
        end

      end
    end
  end
end
