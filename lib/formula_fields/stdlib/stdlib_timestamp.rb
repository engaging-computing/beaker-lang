require 'date'

module FormulaFields
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

    # Takes a parameter for year, month, day, hour, minutes, seconds and returns
    #   a timestamp object reflecting those values.
    # All timestamps during computation are UTC timestamps.
    @stdlib.add 'datetime', datetime
  end

  def self.datetime
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
    end, [Contract.new(:number)] * 6)
  end
end

FormulaFields.init_timestamp
