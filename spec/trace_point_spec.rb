require 'rspec'

describe 'Old API' do

  it 'should trace everything' do

    traces = []
    tracer = lambda do |event, file, line, id, binding, klass|
      traces << "#{event}, #{file}, #{line}, #{klass}"
    end

    set_trace_func tracer
    # here, the size is still small (~2), but
    # until the expectation is checked, much more traces will accumulate
    p traces.size
    expect(traces).to have_at_least(100).items
  end

  # new traces keep coming in fast, so the iteration is never finished
  pending 'should go into an infinite loop if iterating over the container with the traces' do
    traces = []
    tracer = lambda do |event, file, line, id, binding, klass|
      traces << "#{event}, #{file}, #{line}, #{klass}"
    end
    set_trace_func tracer
    traces.grep /singleton_method_added/
  end

end

describe 'new API' do

  traces = []
  let(:tracer) { tracer = TracePoint.new do |tp|
    traces << "#{tp.event}, #{File.basename(tp.path)}, #{tp.lineno}, #{tp.defined_class}, #{tp.method_id}"
  end
  }

  # that's pretty unimpressive
  it 'should capture everything' do
    traces = []

    tracer.enable
    def money_on_the_table; 'bam'; end
    tracer.disable

    traced = traces.grep /singleton_method_added/
    # 1 item for a c_call, another 1 for the c_return
    expect(traced).to have(2).items
  end


  # ah, interesting
  it 'should be switchable' do
    traces = []

    tracer.enable
    10.times{ p 'Nananananananana Leader!'}
    tracer.disable

    def gimme; 'bam'; end

    expect(traces.grep /singleton_method_added/).to be_empty
  end

  it 'can be passed a block to work with' do
    traces = []
    tracer.enable do
      tracer.enable
    end
    traced = traces.grep /singleton_method_added/
    expect(traced).to have(2).items
  end

  #trace = TracePoint.new(:raise) do |t|
  #  puts "WOOOOO!!"
  #end
  #
  #require "file_that_doesnt_exist"
  #WOOOOO!!
  #       [36, :raise, #<LoadError: cannot load such file -- file_that_doesnt_exist>]

  #trace = TracePoint.new(:return) do |t|
  #  puts "#{t.method_id} has just done its thing."
  #end
  #trace.enable #=>

end

