require_relative '../deferred_wrapper'
require_relative 'match_stdout'

# the way the wrapper works now, the wrapper payload has to be hardcoded
# TODO: find a way to pass a block/proc/lambda to be executed before/after the original method



describe Wrapper do

  it 'should run with rspec' do

    # where does the stuff in the current example come from - where is it defined?
    puts "local source: #{self.class.instance_method(self.class.instance_methods.first).source_location}"

    # puts "config: #{RSpec.configuration.inspect}"
    puts "source location of filter exclusions: #{RSpec.configuration.filter_manager.exclusions[:if].source_location}" #instance_variable_get(:@exclusions)}"
    # puts "and other introspections: #{RSpec.methods(false)}"
    # puts "world: #{RSpec.world.inspect}"

  end

  it 'should wrap already defined methods' do

    class Wrapped
      include Wrapper

      def yawn
        'wuhaa'
      end

      wrap_me :yawn
    end

    expect {
      wrapped = Wrapped.new
      wrapped.yawn
    }.to match_stdout /wrapper payload goes here/#/we're done now/
  end

end