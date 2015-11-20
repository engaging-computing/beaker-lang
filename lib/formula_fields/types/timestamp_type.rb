require 'date'

module FormulaFields
  class TimestampType < BaseType
    def initialize(value)
      if value.is_a? DateTime
        super(value)
      elsif value.is_a? String
        date = begin
          DateTime.parse(value)
        rescue
          nil
        end
        super(date)
      else
        super(nil)
      end
    end

    def type
      :timestamp
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      case sym
      when :eq then (@value <=> r.get) == 0
      when :ne then (@value <=> r.get) != 0
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then (@value <=> r.get) < 0
      when :le then (@value <=> r.get) <= 0
      when :gt then (@value <=> r.get) > 0
      when :ge then (@value <=> r.get) >= 0
      end
    end

    def to_s
      self.is_nothing? ? '' : @value.strftime('%Y/%m/%d %H:%M:%S')
    end

    def self.elapsed(l, r)
      if l.is_nothing? or r.is_nothing?
        NumberType.new(nil)
      else
        NumberType.new((l.get - r.get) * 24 * 60 * 60)
      end
    end
  end
end
