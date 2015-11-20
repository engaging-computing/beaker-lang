module FormulaFields
  class BooleanType < BaseType
    def initialize(value)
      if value.is_a? TrueClass
        super(true)
      else
        super(false)
      end
    end

    def is_nothing?
      false
    end

    def type
      :bool
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      case sym
      when :eq then @value == r.get
      when :ne then @value != r.get
      end
    end

    def to_s
      @value ? 'true' : 'false'
    end
  end
end
