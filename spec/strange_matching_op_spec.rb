require 'rspec'
require 'English'

# I was not aware that the complementary operator to =~ was !~ and not !=~
# which though make look nice, is actually two operators: !=(~). Some confusion ensued.

describe 'the =~ operator, shortly' do

  it 'should return the index of a match' do
    expect('abc' =~ /b/).to be 1
  end

  it 'should return nil if no match' do
    expect('cde' =~ /b/).to be nil
  end

  it 'negated, a 1 should return false' do
    expect(!('abc' =~ /b/)).to be false
  end
end

describe 'the ~ operator' do

  # the ~ operator (http://www.ruby-doc.org/core-2.1.0/Regexp.html#method-i-7E)
  # It matches the last line from STDIN
  # ~rxp is equivalent to rxp =~ $_

  # http://stackoverflow.com/questions/13699410/what-is-0-1-in-ruby

  # you can also call it $LAST_READ_LINE
  # https://github.com/ruby/ruby/blob/trunk/lib/English.rb

  it 'should not match anything if called just like that' do
    expect(~/b/).to be nil
  end

  it 'should match the content of $_' do
    $_ = "abc"
    expect(~/b/).to be 1
  end

end

describe 'the !=~ operator confusion' do

  it 'should check if ~' do
    expect('abc' !=~/b/).to be true
  end

  it 'should be identical the result of the expanded version' do
    expect('abc' !=(~/b/)).to be true
  end

  it 'should be identical the result of the further expanded version' do
    expect('abc' !=(/b/ =~ $_)).to be true
  end


  it 'should be modified bo the last read line the result of the further expanded version' do
    $LAST_READ_LINE = 'abc'
    expect('abc' !=(/b/ =~ $_)).to be true
  end

  it 'should be modified bo the last read line in the compact version' do
    $LAST_READ_LINE = 'abc'
    expect('abc' !=~/b/).to be true
  end

end