
describe 'filtering a vanilla hash' do

  let(:h){{:key1 => 'foo', :to_removeY => 'baz', :key2 => 'bar', :to_removeX => 'baz'}}
  let(:result){{:key1 => 'foo', :key2 => 'bar'}}

  it 'should be filterable by :reject' do
    filtered = h.reject { |k, v| k =~/remove/ }
    expect(filtered).to eq result
  end
end

require 'active_support/core_ext/hash/slice'

describe 'filtering with activesupport' do

  let(:h){{:key1 => 'foo', :to_removeY => 'baz', :key2 => 'bar', :to_removeX => 'baz'}}
  let(:result){{:key1 => 'foo', :key2 => 'bar'}}

  it 'should be filterable by :slice' do

    # with slice, you name the keys you want to keep
    filtered = h.slice(:key1, :key2)
    expect(filtered).to eq result
  end

end
