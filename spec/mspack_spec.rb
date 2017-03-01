require 'spec_helper'

describe Mspack do
  it 'has a version number' do
    expect(Mspack::VERSION).not_to be nil
  end

  it 'verifies the native library operation' do
    expect(Mspack.test).to be true
  end
end
