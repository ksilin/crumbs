describe 'trying array conjunction by splicing' do

  let(:a1) { [1, 2, 3, 4, 5] }
  let(:a2) { [4, 5, 6] }

  it 'should splice' do
    p "a1[a1.length, 0] #{a1[a1.length, 0]}"

    # the syntax a[1, 2] means a subarray of length 2, satrting at index 1


    # here, we grab an empty array that consists of 0 elements
    # with teh first element being the element after the last
    # and assign a second array to it, making it part of the first array.
    # I wonder whether if you change on object, the other will be changed too
    length = a1.length
    a1[length, 0] = a2

    p "a1[a1.length, 0] #{a1[a1.length, 0]}" # => []
    p "a1[0, 1] #{a1[0, 1]}" # => 1
    p "a1[1, 0] #{a1[1, 0]}" # => []

    expect { a1[0, 1, 2] }.to raise_error
    p "a1: #{a1}"

    a1.insert(a1.length, *a2)
    p a1
  end


  let(:a1) { [Object.new, Object.new, Object.new] }
  let(:a2) { [Object.new] }

  it 'should share the objects after appending' do

    a1[a1.length, 0] = a2

    expect(a1[-1].__id__).to be == a2[0].__id__
  end

  it 'should share the objects after appending 2' do

    def (a2[0]).val
      "hi"
    end

    a1[a1.length, 0] = a2

    expect(a1[0]).not_to respond_to :val
    # and there it is
    expect(a1[-1]).to respond_to :val
  end

end

