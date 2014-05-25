require 'rspec'

# Date#parse just tries to create a date out of everything,
# guessing quite wildly sometimes
describe 'Lenient parsing' do

  # woot
  it 'should extract a Date from a seemingly regular filename' do
    expect(Date.parse('foobar.markdown')).to eq Date.new(2014,3,1)
  end

  # it parses the 'mar' as the closest march
  it 'found the culprit' do
    expect(Date.parse('mar')).to eq Date.parse('2014-03-01')
  end

end