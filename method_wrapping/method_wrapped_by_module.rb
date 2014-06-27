# a 'classic' - alias method, new definition wraps the old one
# downside - the original method has to be already defined
# when the macro method is called

module Aliaser

  def log_caller(meth)

    alias_method "#{meth}_unlogged", meth

    define_method meth do |*args|
      puts "#{meth} called by #{caller}"
      send "#{meth}_unlogged", *args
    end

  end
end


class Snobbish
  extend Aliaser

  def avoid
    puts "avoid: I dont remember"
  end

  log_caller :avoid
end

Snobbish.new.avoid

# using method instances (`instance_method`) to redefine the method
# the module wraps all defined methods of the including class
# downside - the original method has to be already defined
# when the module is included

module RebindAll

  def self.included(base)
    methods = base.instance_methods(false) # we don't wrap private methods

    base.class_eval do

      methods.each do |method|

        original_method = instance_method(method)
        define_method(method) do |*args, &block|
          puts "method #{method} was called by #{caller}"
          original_method.bind(self).call(*args, &block)
        end
      end
    end
  end
end

class UnaskedFor

  def unwrapped
    puts "unwrapped called"
  end

  # I have to include the module after defining the methods.
  # This sucks, how do I circumvent it?
  include RebindAll
end

UnaskedFor.new.unwrapped

# same as above -
# using method instances (`instance_method`) to redefine the method
# but with a macro method
# downside - the original method has to be already defined
# when the macro method is called

module RebindMacro

  def log_it(method)
    puts "logging #{method} from now on"
    original_method = instance_method(method)
    define_method(method) do |*args, &block|
      puts "method #{method} was called by #{caller}"
      original_method.bind(self).call(*args, &block)
    end
  end
end

class AskedFor
  extend RebindMacro

  def unwrapped
    puts "unwrapped called"
  end

  log_it :unwrapped
end

AskedFor.new.unwrapped

# another approach - define the macro method in object
# to eliminate the need to include or extend anything
# downside - the original method has to be already defined
# when the macro method is called

class Object

  def log_method(method)
    puts "logging #{method} from now on"
    original_method = instance_method(method)
    define_method(method) do |*args, &block|
      puts "method #{method} was called by #{caller}"
      original_method.bind(self).call(*args, &block)
    end
  end

end

class AboutToLog

  def jump
    puts "jumping"
  end

  #still cannot call before the method
  log_method :jump
end

# this approach does not work - I had hoped that when teh method look up
# looks into the prepended module, it uses `respond_to` and `method_missing`
# it looks like it doesnt

module NamedPrepender

  def respond_to?(m)
    true
  end

  def method_missing(m, *args, &block)
    puts "There's no method called #{m} here -- please try again."
  end
end

class Prepped
  prepend NamedPrepender

  def some_method
    puts 'some method'
  end

end

Prepped.new.some_method

# another naive approach thet does not work - overwriting `send`
# works only for explicit invocations of `send`
class Object

  alias_method :old_send, :send

  def send(method_name, parameters = nil)
    puts "received call to #{method_name}"
    old_send(method_name, *parameters)
  end
end

class MyClass

  def bark
    puts 'woof woof'
  end
end

MyClass.new.bark
MyClass.new.send(:bark)


# a module that rewrites the class by a derived one
# this does nothing to solve our task, but is funny
# TODO: redefine method on the derived class

module Deriver

  def self.included(base)
    puts "base #{base} class: #{base.class}"
    new_class = Class.new(base) do
      def this_wasnt_there_before
        puts 'I can be called now'
      end
    end
    puts "removing the original class definition of #{base.to_s}"
    Object.send(:remove_const, base.to_s)
    new_class = Object.const_set base.to_s, new_class
    puts "new class: #{new_class}"
  end

end

class DD
  include Deriver

  def been_there
    puts 'I have been there before'
  end
end

a = DD.new
a.this_wasnt_there_before
a.been_there

# a diversion - wrapping method is easy, if you are doing it for a single class
# and you know the names of the methods - just use prepend

module Aliaser
  def welcome
    puts "welcome called by #{caller}"
    super
  end
end

class Friendly
  prepend Aliaser

  def welcome
    puts "Hi"
  end
end

Friendly.new.welcome

# The only method allowing wrapping a method before the method itself has been declared
# prepend an anonymous module with the wrapping method to the class
# downside - the original method does not have to exist, yo you would get
# an error on `super`
# available since ruby 2.0

module Prepender

  def wrap_me(*method_names)
    method_names.each do |m|
      proxy = Module.new do
        define_method(m) do |*args|
          puts "the method '#{m}' is about to be called"
          super *args
        end
      end
      self.prepend proxy
    end
  end

  def wrap_me_once(*method_names)
    method_names.each do |m|
      proxy.send(:define_method, m) { |*args|
        puts "the method '#{m}' is about to be called"
        super *args
      }
    end
  end

  def proxy
    if @proxy.nil?
      @proxy = Module.new
      self.prepend @proxy
    end
    @proxy
  end

end

class Dogbert
  extend Prepender

  wrap_me_once :bark, :deny

  def bark
    puts 'Bah!'
  end

  def deny
    puts 'You have no proof!'
  end
end

Dogbert.new.bark
Dogbert.new.deny

# TODO: use `method_added`, the method definition callback
# to wrap the method on-the-fly

# Watch out - the redefinition may themselves trigger the callback.

module Readder

  def wrapped_names
    @wrapped_names ||= []
  end

  def self.extended(child)

    child.send(:define_singleton_method, :method_added) { |method_name|
      puts "wrapping #{method_name}"



      # TODO: it seems wrong to cache method names since can only wrap the first definition
      # but how do I prevent redefining the method until the stack overflows
      if wrapped_names.include?(method_name)
        puts "method #{method_name} is already wrapped"
        wrapped_names.delete(method_name)
      else
        wrapped_names << method_name

        proxy.send(:define_method, method_name) { |*args|
          puts "the method '#{method_name}' is about to be called"
          super *args
        }

        # original_method = instance_method(method_name)
        # puts "method: #{original_method}"
        # define_method(method_name) do |*args, &block|
        #   puts "method #{method_name} was called by #{caller}"
        #   original_method.bind(self).call(*args, &block)
        # end
      end
      # end
    }
  end

  def proxy
    if @proxy.nil?
      @proxy = Module.new
      self.prepend @proxy
    end
    @proxy
  end
end

class Ratbert
  extend Readder

  def chew
    puts 'om nom nom'
  end
end

puts "puts Ratbert.methods: #{Ratbert.methods.grep(/added/)}"
puts "puts Ratbert.singleton_methods: #{Ratbert.singleton_methods}"
puts "puts Ratbert.class.singleton_methods: #{Ratbert.class.singleton_methods}"
puts "puts Ratbert.class.methods: #{Ratbert.class.methods.grep(/added/)}"

Ratbert.new.chew
# Ratbert.send(:method_added, :wrong)

# TODO: and now wrap methods without modifying the wrapped classes
# traverse object space for classes and methods by name and wrap them