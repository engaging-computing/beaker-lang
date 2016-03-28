require 'date'

module Beaker
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
      elapsed2(l, r, nil)
    end

    def self.elapsed2(l, r, units)
      if l.is_nothing? or r.is_nothing?
        NumberType.new(nil)
      else
        tc1 = l.get.strftime('%s').to_i
        tc2 = r.get.strftime('%s').to_i
        delta = (tc1 - tc2).abs

        units = units.nil? ? TextType.new('seconds') : units
        conv_factor = case units.get
                      when 'second', 'seconds' then 0
                      when 'minute', 'minutes' then 1
                      when 'hour', 'hours' then 2
                      when 'day', 'days' then 3
                      when 'week', 'weeks' then 4
                      when 'month', 'months' then 5
                      when 'year', 'years' then 6
                      else 0
                      end

        convs = [60.0, 60.0, 24.0, 7.0, 4.348125, 12.0][0, conv_factor]
        conv_delta = convs.reduce(delta, :/)
        NumberType.new(conv_delta)
      end
    end

    def self.offset(l, r)
      if l.is_nothing? or r.is_nothing?
        TimestampType.new(nil)
      else
        TimestampType.new(l.get + (r.get / 86400))
      end
    end
  end
end
