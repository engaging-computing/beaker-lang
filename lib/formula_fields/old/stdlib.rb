module FormulaFields
  @stdlib = Environment.new

  @stdlib.add_ns 'True', BooleanType.new(true)
  @stdlib.add_ns 'False', BooleanType.new(false)
  @stdlib.add_ns 'if', FunctionType.new('if', lambda do |env, cond, x, y|
    if x.type != y.type
      fail ArgumentTypeError.new('if', [:bool, :any, :any], [:bool, x.type, y.type])
    elsif cond.get
      x
    else
      y
    end
  end, [Contract.new(:bool), AnyContract.new, AnyContract.new])

  def self.stdlib
    @stdlib
  end
end
