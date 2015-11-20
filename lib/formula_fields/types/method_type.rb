module FormulaFields
  class MethodType < FunctionType
    def initialize(name, func, contract)
      super(name, func, contract)
      @this = nil
    end

    def parent(this)
      @this = this
    end

    def call(env, args)
      super(env, [@this] + args)
    end

    def is_method?
      true
    end
  end
end
