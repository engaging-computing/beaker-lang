module Beaker
  class NumberType < BaseType
    def initialize(value)
      if value.nil? or Float(value).nan? or value.abs == Float::INFINITY
        super(nil)
      else
        super(Float(value))
      end
    end

    def type
      :number
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      # handle nils
      l_val = is_nothing? ? 0 : @value
      r_val = r.is_nothing? ? 0 : r.get
      cmp_val = (l_val - r_val).abs

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
      l_val = is_nothing? ? 0 : @value
      r_val = r.is_nothing? ? 0 : r.get

      case sym
      when :lt then l_val < r_val
      when :le then l_val <= r_val
      when :gt then l_val > r_val
      when :ge then l_val >= r_val
      end
    end

    def to_s
      if is_nothing?
        ''
      elsif @value == (y = Integer(@value))
        # Handles the case where value is a whole number, and you don't want decimals
        y.to_s
      else
        @value.to_s
      end
    end

    def self.to_s(x)
      if x.nil?
        ''
      elsif x == (y = Integer(x))
        y.to_s
      else
        x.to_s
      end
    end

    def self.arithmetic(op, l, r)
      if l.is_nothing? or r.is_nothing?
        NumberType.new(nil)
      else
        x = case op
            when :add then l.get + r.get
            when :sub then l.get - r.get
            when :mul then l.get * r.get
            when :div then l.get / r.get
            when :mod then l.get % r.get
            when :pow then (l.get < 0 and r.get.abs < 1) ? nil : l.get**r.get
            end
        if x.nil? or x.abs == Float::INFINITY or x.nan?
          NumberType.new(nil)
        else
          NumberType.new(x)
        end
      end
    end

    def self.fromText(x)
      num = Float(x.get)
      NumberType.new(num)
    rescue
      NumberType.new(nil)
    end
  end
end
