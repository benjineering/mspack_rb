require 'spec_helper'

module Mspack
  
  describe Mspack do
    describe '.test' do
      it 'returns true if libmspack is installed and working' do
        expect(Mspack.test).to be true
      end
    end

    describe '.ensure_path' do
      before(:each) do
        FileUtils.rm_rf("#{TEMP_DIR}/.")
      end

      it 'raises an error if dir is not an existing, writable directory' do
        filename = 'p00t'
        dir = "#{TEMP_DIR}/non_writable"
        expect { Mspack.ensure_path(filename, dir) }.to raise_error(PathError)

        FileUtils.mkdir(dir, mode: 0444)
        expect { Mspack.ensure_path(filename, dir) }.to raise_error(PathError)
      end

      it 'does nothing if the directory exists' do
        filename = '/p00ts/wo0tys'
        path = "#{TEMP_DIR}#{filename}"
        FileUtils.mkdir_p(path)
        mtime = File.mtime(path)
        Mspack.ensure_path(filename, TEMP_DIR)
        expect(File.mtime(path)).to eq(mtime)
      end

      it 'expands the dir path, so you can use ~ and . etc' do
        filename = '/./w00t'
        path = Mspack.ensure_path(filename, TEMP_DIR_UNEXPANDED)
        expect(path).to eq("#{TEMP_DIR}/w00t")
      end
      
      it 'creates writable parent folders for file.filename' do
        filename = '/blob?al0rt'
        full_path = Mspack.ensure_path(filename, TEMP_DIR_UNEXPANDED)
        path = File.dirname(full_path)
        expect(File.directory?(path)).to be true
        expect(File.writable?(path)).to be true
      end

      it 'only creates up to the directory portion of the path' do
        # i.e. ignore the file name and extension when creating dirs
        filename = '/blob?al0rt.exe'
        path = Mspack.ensure_path(filename, TEMP_DIR)
        expect(File.exist?(TEMP_DIR)).to be true
        expect(File.exist?(path)).to be false
      end
      
      it 'raises an error if the final, expanded path is outside of dir' do
        filename = "../#{TEMP_DIR_UNEXPANDED}/../plorpus"

        expect { 
          Mspack.ensure_path(filename, TEMP_DIR) 
        }.to raise_error(PathError)
      end
    end
  end
end
