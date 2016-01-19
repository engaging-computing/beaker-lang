module Beaker
  def self.init_bool
    # Take an arbitrary type and convert it into a bool.  If it is a number and is
    #   either nil or 0, it is false. Otherwise it is true.  If it is a bool already,
    #   it is copied.  All other values are false.
    @stdlib.add 'bool', FunctionType.new('bool', lambda do |env, x|
      type = x.type == :array ? x.contains : x.type
      case type
      when :number then BooleanType.new(!(x.get.nil? or x.get == 0))
      when :bool then BooleanType.new(x.get)
      else BooleanType.new(false)
      end
    end, [OrContract.new([Contract.new(:number), Contract.new(:bool)])])
  end
end

Beaker.init_bool
