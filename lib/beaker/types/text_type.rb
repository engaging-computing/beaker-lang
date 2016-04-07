module Beaker
  class TextType < BaseType
    def initialize(value)
      super(value.to_s)
    end

    def is_nothing?
      @value.empty?
    end

    def type
      :text
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

    def to_s
      "\"#{@value}\""
    end

    def self.concatenate(l, r)
      temp_l = l.get.is_a?(Numeric) ? NumberType.to_s(l.get) : l.get.to_s
      temp_r = r.get.is_a?(Numeric) ? NumberType.to_s(r.get) : r.get.to_s
      TextType.new(temp_l + temp_r)
    end

    def self.repeat(l, r)
      if r.is_nothing?
        TextType.new('')
      else
        sign = [1, 1, -1][r.get <=> 0]
        base = r.get.abs.floor
        part = r.get.abs - base

        newstr = l.get * base + l.get[0, (l.get.length * part).round]
        if sign == 1
          TextType.new(newstr)
        else
          TextType.new(newstr.reverse)
        end
      end
    end
  end
end
