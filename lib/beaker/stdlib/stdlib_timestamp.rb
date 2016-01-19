require 'date'

module Beaker
  def self.init_timestamp
    # Takes an arbitrary value and returns a timestamp object.  If the value is
    #   a number, the number is interpreted as a unix timestamp.  If the value
    #   is a text type, Ruby will try to parse it as a timestamp.  If the value
    #   is a timestamp, it will be copied.  All other values result in a nil
    #   timestamp.
    @stdlib.add 'timestamp', FunctionType.new('timestamp', lambda do |env, x|
      type = x.type == :array ? x.contains : x.type
      case type
      when :number then TimestampType.new()
      when :text then TimestampType.new()
      when :timestamp then TimestampType.new(x.get)
      else TimestampType.new(nil)
      end
    end, [OrContract.new([Contract.new(:number), Contract.new(:text), Contract.new(:timestamp)])])

    @stdlib.add 'datetime', time_datetime
    @stdlib.add 'offset', time_offset
    @stdlib.add 'elapsed', time_elapsed

    # Functions for getting the second, minute, ..., all the way to year
    @stdlib.add 'second', time_get_with_sym('second', :sec)
    @stdlib.add 'minute', time_get_with_sym('minute', :min)
    @stdlib.add 'hour', time_get_with_sym('hour', :hour)
    @stdlib.add 'day', time_get_with_sym('day', :day)
    @stdlib.add 'week', time_get_with_sym('week', :cweek)
    @stdlib.add 'weekday', time_get_with_sym('weekday', :wday)
    @stdlib.add 'month', time_get_with_sym('month', :month)
    @stdlib.add 'year', time_get_with_sym('year', :year)

    # Functions for getting the AM/PM-ness, and names of weekdays and months
    @stdlib.add 'am_pm', time_get_with_fmt('am_pm', '%p')
    @stdlib.add 'weekday_name', time_get_with_fmt('weekday_name', '%A')
    @stdlib.add 'month_name', time_get_with_fmt('month_name', '%B')
  end

  # General function for getting time components from a time stamp
  def self.time_get_with_sym(name, sym)
    FunctionType.new(name, lambda do |env, x|
      if x.is_nothing?
        NumberType.new(nil)
      else
        NumberType.new(x.get.send(sym))
      end
    end, [Contract.new(:timestamp)])
  end

  # General function for getting textual time components from a time stamp
  def self.time_get_with_fmt(name, fmt)
    FunctionType.new(name, lambda do |env, x|
      if x.is_nothing?
        TextType.new('')
      else
        TextType.new(x.get.strftime(fmt))
      end
    end, [Contract.new(:timestamp)])
  end

  # Takes a parameter for year, month, day, hour, minutes, seconds and returns
  #   a timestamp object reflecting those values.
  # All timestamps during computation are UTC timestamps.
  def self.time_datetime
    FunctionType.new('datetime', lambda do |env, yr, mo, dy, hr, mi, sc|
      yr = yr.is_nothing? ? 0 : yr.get
      mo = mo.nil? || mo.is_nothing? ? 1 : mo.get
      dy = dy.nil? || dy.is_nothing? ? 1 : dy.get
      hr = hr.nil? || hr.is_nothing? ? 0 : hr.get
      mi = mi.nil? || mi.is_nothing? ? 0 : mi.get
      sc = sc.nil? || sc.is_nothing? ? 0 : sc.get

      total_months = (yr * 12) + (mo - 1)
      total_days = (dy - 1) + (hr / 24) + (mi / 1440) + (sc / 86400)

      new_date = DateTime.new(0, 1, 1, 0, 0, 0)
      new_date = new_date >> total_months
      new_date += total_days

      TimestampType.new(new_date)
    end, [Contract.new(:number)] + [Contract.new(:number, true)] * 5)
  end

  def self.time_offset
    FunctionType.new('offset', lambda do |env, time, dist, units|
      units = units.nil? ? TextType.new('seconds') : units
      dist_val = dist.is_nothing? ? 0 : dist.get
      if time.is_nothing?
        TimestampType.new(nil)
      else
        case units.get
        when 'second', 'seconds' then TimestampType.new(time.get + (dist_val / 86400))
        when 'minute', 'minutes' then TimestampType.new(time.get + (dist_val / 1440))
        when 'hour', 'hours' then TimestampType.new(time.get + (dist_val / 24))
        when 'day', 'days' then TimestampType.new(time.get + dist_val)
        when 'week', 'weeks' then TimestampType.new(time.get + (dist_val * 7))
        when 'month', 'months' then TimestampType.new(time.get >> dist_val)
        when 'year', 'years' then TimestampType.new(time.get >> (dist_val * 12))
        else this
        end
      end
    end, [Contract.new(:timestamp), Contract.new(:number), Contract.new(:text, true)])
  end

  def self.time_elapsed
    FunctionType.new('elapsed', lambda do |env, l, r, units|
      TimestampType.elapsed2(l, r, units)
    end, [Contract.new(:timestamp), Contract.new(:timestamp), Contract.new(:text, true)])
  end
end

Beaker.init_timestamp
