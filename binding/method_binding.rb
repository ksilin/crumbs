# turns out, you can only rebind a method to an instance of the same class.
# this is somehow quite unrubyish.

# TODO: ask on SO

MethodAsylum = Class.new do
  def rule(n)
    n.modulo(number).zero? ? string : ''
  end
end


rule_method = MethodAsylum.instance_method :rule

rule13 = Object.new

# => bind argument must be an instance of MethodAsylum (TypeError)
rule_method.bind(rule13)