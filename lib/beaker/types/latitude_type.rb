module Beaker
  class LatitudeType < BaseType
    def initialize(value)
      if value.nil?
        super(nil)
      else
        # this is bit is more complicated that it should be because the eq used
        # for wrapping the coords turns 90 degrees into -90 for latitude and
        # 180 into -180 for longitude
        num = Float(value)
        num_mod = ((num + 90) % 180 - 90).abs
        if num < 0
          super(-1 * num_mod)
        else
          super(num_mod)
        end
      end
    end

    def type
      :latitude
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
      LatitudeType.new(num)
    rescue
      LatitudeType.new(nil)
    end
  end
end
