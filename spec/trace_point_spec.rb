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

  it 'should capture everything' do
    traces = []
    tracer = TracePoint.new do |tp|
      traces << "#{tp.event}, #{File.basename(tp.path)}, #{tp.lineno}, #{tp.defined_class}, #{tp.method_id}"
    end

    tracer.enable
    expect(traces).to have_at_least(100).items
    def money_on_the_table; 'bam'; end
    tracer.disable

    gr = traces.grep /singleton_method_added/
    # 1 item for a c_call, another 1 for the c_return
    expect(gr).to have(2).item
  end

  it 'should be switchable' do
    traces = []
    tracer = TracePoint.new do |tp|
      traces << "#{tp.event}, #{File.basename(tp.path)}, #{tp.lineno}, #{tp.defined_class}, #{tp.method_id}"
    end

    tracer.enable
    expect(traces).to have_at_least(100).items
    tracer.disable

    def money_on_the_table; 'bam'; end

    expect(traces.grep /singleton_method_added/).to be_empty
  end

end

