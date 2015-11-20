module FormulaFields
  class BaseType
    attr_reader :value

    def initialize(value)
      @value = value
    end

    # is_nothing?: is the type currently nothing?
    def is_nothing?
      @value.nil?
    end

    # can_eq?: can this type be tested for equality/inequality?
    def can_eq?
      false
    end

    # can_ord?: can this type be ordered?
    def can_ord?
      false
    end

    # get: gets a usable value from the object (number, text, time, lat, lon)
    def get
      @value
    end

    # to_s: convert the type to a string
    def to_s
      self.is_nothing? ? '' : @value.to_s
    end
  end
end
