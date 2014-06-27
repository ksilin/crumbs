module Wrapper

  def initialize
    puts "We were planning on wrapping #{methods_to_wrap}"
    puts "and ended up wrapping #{methods_wrapped}"

    if wrapped_too_much.any?
      puts "wait, we have wrapped too much #{wrapped_too_much}"
    end
    if remaining_unwrapped.any?
      puts "wait, we wanted wrap some more methods first: #{remaining_unwrapped}"
    end
    if (wrapped_too_much + remaining_unwrapped).empty?
      puts "so we're done now"
    end
  end

  def wrapped_too_much
    methods_wrapped - methods_to_wrap
  end

  def remaining_unwrapped
    methods_to_wrap - methods_wrapped
  end

  def methods_to_wrap
    self.class.methods_to_wrap
  end

  def methods_wrapped
    self.class.methods_wrapped
  end


  def self.included base
    base.extend MacroMethodAndInstanceVars

    def base.wrap_method method_name
      methods_wrapped << method_name
      original_method = instance_method(method_name)
      define_method(method_name) do |*args, &block|
        # puts "method #{method_name} was called by #{caller}"
        puts 'wrapper payload goes here'
        original_method.bind(self).call(*args, &block)
      end
      puts "wrapped #{methods_wrapped}"
    end

    def base.method_added method_name
      puts "method #{method_name} is being added to #{self}"

      if !methods_to_wrap.include? method_name
        puts 'i should not be wrapping this'
        return
      end

      if methods_wrapped.include? method_name
        puts 'it should be wrapped already, skipping'
        return
      end

      wrap_method method_name
    end
  end

  module MacroMethodAndInstanceVars

    def wrap_me(*method_names)
      methods_to_wrap.push *method_names

      (method_names & instance_methods).each do |method_name|
        wrap_method method_name
      end
    end

    # cannot use initialize or a self.extended hook
    # so resorting to regular memoizing getters
    def methods_to_wrap
      @methods_to_wrap ||= []
    end

    def methods_wrapped
      @methods_wrapped ||= []
    end

  end
end

class Dogbert
  include Wrapper

  wrap_me :bark, :deny, :something_else

  def bark
    puts 'Bah!'
  end

  def deny
    puts 'You have no proof!'
  end
end

Dogbert.new.bark
Dogbert.new.deny

class Ratbert
  include Wrapper

  def squeak
    puts 'Peep!'
  end

  def rat_out
    puts 'If was him!'
  end

  wrap_me :squeak, :rat_out

end

Ratbert.new.squeak
Ratbert.new.rat_out

# r = /added/
# puts "puts Dogbert.methods #{r}: #{Dogbert.methods.grep(r)}"
# puts "puts Dogbert.instance_methods #{r}: #{Dogbert.instance_methods.grep(r)}"
# puts "puts Dogbert.singleton_methods: #{Dogbert.singleton_methods}"
# puts "puts Dogbert.class.singleton_methods: #{Dogbert.class.singleton_methods}"
# puts "puts Dogbert.class.methods #{r}: #{Dogbert.class.methods.grep(r)}"