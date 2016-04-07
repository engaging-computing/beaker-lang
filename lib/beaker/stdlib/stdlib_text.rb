module Beaker
  def self.init_text
    @stdlib.add 'strlen', FunctionType.new('strlen', lambda do |env, t|
      NumberType.new(t.get.length)
    end, [Contract.new(:text)])

    @stdlib.add 'capitalize', FunctionType.new('capitalize', lambda do |env, t|
      TextType.new(t.get.capitalize)
    end, [Contract.new(:text)])

    @stdlib.add 'upper', FunctionType.new('upper', lambda do |env, t|
      TextType.new(t.get.upcase)
    end, [Contract.new(:text)])

    @stdlib.add 'lower', FunctionType.new('lower', lambda do |env, t|
      TextType.new(t.get.downcase)
    end, [Contract.new(:text)])

    @stdlib.add 'swap', FunctionType.new('swap', lambda do |env, t|
      TextType.new(t.get.swapcase)
    end, [Contract.new(:text)])

    @stdlib.add 'reverse', FunctionType.new('reverse', lambda do |env, t|
      TextType.new(t.get.reverse)
    end, [Contract.new(:text)])

    @stdlib.add 'trim', FunctionType.new('trim', lambda do |env, t|
      TextType.new(t.get.strip)
    end, [Contract.new(:text)])

    @stdlib.add 'substr', FunctionType.new('substr', lambda do |env, t, spos, epos|
      min_len = 0
      max_len = t.get.length
      spos = NumberType.new(min_len) if spos.is_nothing? or spos.get < min_len
      epos = NumberType.new(max_len) if epos.is_nothing? or epos.get > max_len
      TextType.new(t.get[spos.get, epos.get - spos.get])
    end, [Contract.new(:text), Contract.new(:number), Contract.new(:number)])

    # Take an arbitrary type and convert it into text.  Booleans are converted to
    #   either 'true' or 'false'.  Timestamps are converted to 'yyyy/mm/dd hh:mm:ss'
    #   format.  Locations are converted to '(lat, lon)' format.  The rest are
    #   just converted straight to text.  If no match is found, the empty string
    #   is returned.
    @stdlib.add 'text', FunctionType.new('text', lambda do |env, x|
      if x.get.nil?
        # so strftime doesn't implode
        TextType.new('')
      else
        type = x.type == :array ? x.contains : x.type
        case type
        when :bool then TextType.new(x.get ? 'true' : 'false')
        when :number then TextType.new(NumberType.to_s(x.get))
        when :text then TextType.new(x.get)
        when :timestamp then TextType.new(x.get.strftime('%Y/%m/%d %H:%M:%S'))
        when :latitude then TextType.new(NumberType.to_s(x.get))
        when :longitude then TextType.new(NumberType.to_s(x.get))
        when :location then TextType.new("(#{NumberType.to_s(x.get[0])}, #{NumberType.to_s(x.get[1])})")
        else TextType.new('')
        end
      end
    end, [OrContract.new([
      Contract.new(:bool),
      Contract.new(:number),
      Contract.new(:text),
      Contract.new(:timestamp),
      Contract.new(:latitude),
      Contract.new(:longitude),
      Contract.new(:location)])])
  end
end

Beaker.init_text
