require 'spec_helper'

TEST_FILE = File.expand_path("#{__dir__}/../chm_files/test.chm")

module Mspack
  describe ChmDecompressor do
    it 'opens a CHM file' do
      dcom = ChmDecompressor.new
      header = dcom.open(TEST_FILE)
      expect(header).not_to be nil
      expect(header.filename).to eq(TEST_FILE)
    end

    skip 'closes a CHM file' do

    end
  end
end
