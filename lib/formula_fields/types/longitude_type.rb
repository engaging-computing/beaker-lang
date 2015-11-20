module FormulaFields
  class LongitudeType < BaseType
    def initialize(value)
      if value.nil?
        super(nil)
      else
        num = Float(value)
        num_mod = (num + 180) % 360 - 180
        super(num_mod)
      end
    end

    def type
      :longitude
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      cmp_val = (@value - r.get).abs
      delta = 1e-10
      case sym
      when :eq then cmp_val < delta
      when :ne then cmp_val >= delta
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then @value < r.get
      when :le then @value <= r.get
      when :gt then @value > r.get
      when :ge then @value >= r.get
      end
    end

    def to_rad
      @value * Math::PI / 180
    end

    def self.fromText(x)
      num = Float(x.get)
      LongitudeType.new(num)
    rescue
      LongitudeType.new(nil)
    end
  end
end
