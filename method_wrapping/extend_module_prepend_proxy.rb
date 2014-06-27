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