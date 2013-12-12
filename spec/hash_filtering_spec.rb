require 'active_support'

describe 'filtering a hash' do

  let(:h){{:key1 => 'foo', :to_removeY => 'baz', :key2 => 'bar', :to_removeX => 'baz'}}

  it 'should be filterable by keys' do
    p h.reject{|k, v| k =~/remove/}
    p h.collect{|k, v| p "#{k}: #{v}"}
  end

end
