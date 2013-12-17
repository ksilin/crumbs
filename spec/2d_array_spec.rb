require 'rspec'

describe 'Initialization' do

  it 'should initialize eagerly' do
    ary = Array.new(width, []).map {
      (0...height).map { true }
    }

  end
end