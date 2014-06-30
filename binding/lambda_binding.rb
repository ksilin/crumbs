
# name = 'wuzzup'
l = lambda { puts "hi, #{name}"} # it's a Proc
noarg_lambda = lambda {"hello"}
arg_lambda = lambda {|n| "hello, #{n.name}"}
# a is part of the lambda's closure
# l.call # => "hi, wuzzup"

# but can we use another closure, with a different a?

class X
  def name; 'Santa';  end
end

# I have found this solution, but it is not working for me:
# http://stackoverflow.com/questions/3133969/ruby-lambda-context

x = X.new
puts x.instance_eval(&arg_lambda) # => hello Santa. Why is there an implicit argument to the lambda?
x.instance_eval(&noarg_lambda) # => wrong number of arguments (1 for 0) (ArgumentError)
x.instance_eval(&l) # => wrong number of arguments (1 for 0) (ArgumentError)

# I am currently too confused to try some other interesting variants:

# http://stackoverflow.com/questions/10058996/about-changing-binding-of-a-proc-in-ruby
# https://github.com/niklasb/ruby-dynamic-binding

# would it work with an unbound method perhaps?

