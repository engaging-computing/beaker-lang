module FormulaFields
  def self.init_timestamp
    @stdlib.add_class :timestamp,
      'to_number' => MethodType.new('to_number', lambda do |env, this|
        if this.is_nothing?
          NumberType.new(nil)
        else
          NumberType.new(this.get.strftime('%s').to_f)
        end
      end, [MethodContract.new]),
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        if this.is_nothing?
          TextType.new('')
        else
          TextType.new(this.to_s)
        end
      end, [MethodContract.new]),
      'second' => time_component_from_sym('second', :second),
      'minute' => time_component_from_sym('minute', :minute),
      'hour' => time_component_from_sym('hour', :hour),
      'day' => time_component_from_sym('day', :day),
      'week' => time_component_from_sym('week', :cweek),
      'weekday' => time_component_from_sym('weekday', :wday, 1),
      'month' => time_component_from_sym('month', :month),
      'year' => time_component_from_sym('year', :year),
      'am_pm' => time_component_from_fmt('am_pm', '%p'),
      'weekday_name' => time_component_from_fmt('weekday_name', '%A'),
      'month_name' => time_component_from_fmt('month_name', '%B'),
      'offset' => MethodType.new('offset', lambda do |env, this, dist, units|
        units = units.nil? ? TextType.new('seconds') : units
        dist_val = dist.is_nothing? ? 0 : dist.get
        if this.is_nothing?
          TimestampType.new(nil)
        else
          case units.get
          when 'second', 'seconds' then TimestampType.new(this.get + (dist_val / 86400))
          when 'minute', 'minutes' then TimestampType.new(this.get + (dist_val / 1440))
          when 'hour', 'hours' then TimestampType.new(this.get + (dist_val / 24))
          when 'day', 'days' then TimestampType.new(this.get + dist_val)
          when 'week', 'weeks' then TimestampType.new(this.get + (dist_val * 7))
          when 'month', 'months' then TimestampType.new(this.get >> dist_val)
          when 'year', 'years' then TimestampType.new(this.get >> (dist_val * 12))
          else this
          end
        end
      end, [MethodContract.new, Contract.new(:number), Contract.new(:text, true)])

    @stdlib.add_ns 'Time',
      'elapsed' => FunctionType.new('elapsed', lambda do |env, t1, t2, units|
        if t1.is_nothing? or t2.is_nothing?
          NumberType.new(nil)
        else
          tc1 = t1.get.strftime('%s').to_i
          tc2 = t2.get.strftime('%s').to_i
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
      end, [Contract.new(:timestamp), Contract.new(:timestamp), Contract.new(:text, true)]),
      'new' => create_timestamp
  end

  private

  def self.time_component_from_sym(func_name, sym, offset = 0)
    MethodType.new(func_name, lambda do |env, this|
      if this.is_nothing?
        NumberType.new(nil)
      else
        NumberType.new(this.get.send(sym) + offset)
      end
    end, [MethodContract.new])
  end

  def self.time_component_from_fmt(func_name, fmt)
    MethodType.new(func_name, lambda do |env, this|
      if this.is_nothing?
        TextType.new('')
      else
        TextType.new(this.get.strftime(fmt))
      end
    end, [MethodContract.new])
  end

  def self.create_timestamp
    FunctionType.new('new', lambda do |env, yr, mo, dy, hr, mi, sc|
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
end

FormulaFields.init_timestamp
