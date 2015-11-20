module FormulaFields
  @stdlib = Environment.new

  def self.stdlib
    @stdlib
  end

  def self.init
    # Constant value for the literal "true"
    @stdlib.add 'true', BooleanType.new(true)

    # Constant value for the literal "false"
    @stdlib.add 'false', BooleanType.new(false)

    # Takes a boolean, and returns the second argument if true.  Otherwise, it
    #   returns the third argument.
    @stdlib.add 'if', FunctionType.new('if', lambda do |env, cond, x, y|
      check_if_branches(l, r)
      cond.get ? x : y
    end, [Contract.new(:bool), AnyContract.new, AnyContract.new])
  end

  private

  # Takes the two possible branches for the if function and checks to see if
  #   the types match.  The branch types must match exactly, because the array
  #   type has methods that the type of its contents doesn't have.  That's why
  #   I made the "get" function.
  def self.check_if_branches(l, r)
    if l.type != r.type
      fail ArgumentTypeError.new('if', [:bool, l.type, r.type], [:bool, l.type, r.type])
    end
  end
end

FormulaFields.init
