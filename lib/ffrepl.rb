require 'formula_fields'

include FormulaFields

FormulaFields.stdlib.add_ns 'Test',
  'a' => ArrayType.new([1, 2, 3, 4, 5], :number),
  'b' => ArrayType.new(['a', 'b', 'c'], :text),
  'c' => ArrayType.new([30, 60, 90, 120, 150], :latitude),
  'd' => ArrayType.new([45, 90, 135, 180, 225, 270], :longitude),
  'e' => ArrayType.new([
    DateTime.new(2015, 1, 1, 1, 1, 1),
    DateTime.new(2016, 1, 1, 1, 1, 1),
    DateTime.new(2017, 1, 1, 1, 1, 1),
    DateTime.new(2018, 1, 1, 1, 1, 1),
    DateTime.new(2019, 1, 1, 1, 1, 1)
  ], :timestamp),
  'x1' => LongitudeType.new(75),
  'x2' => LongitudeType.new(0),
  'y1' => LatitudeType.new(0),
  'y2' => LatitudeType.new(90),
  'y3' => LatitudeType.new(75),
  't1' => TimestampType.new('2015/8/24 9:31:00'),
  't2' => TimestampType.new('2015/8/24 17:31:00'),
  't3' => TimestampType.new('2015/8/25 9:31:00'),
  't4' => TimestampType.new('2015/8/25 17:31:00'),
  't5' => TimestampType.new('2015/8/26 13:41:32')

FormulaFields.stdlib.add_ns '*', NumberType.new(1)

curr_env = Environment.new(false, FormulaFields.stdlib)

loop do
  print '> '
  $stdout.flush

  input = gets
  break if input.nil?

  begin
    l = Lexer.lex(input.chomp)
  rescue => e
    puts "Lexer error: #{e}"
    next
  end

  begin
    p = Parser.parse(l, verbose: false)[0]
  rescue RLTK::NotInLanguage => e
    puts ParseError.new(e, input)
    next
  rescue => e
    puts "Unknown parse error #{e}"
  end

  puts "  => #{p}"

  begin
    a = p.evaluate(curr_env)
  rescue FormulaFields::Error => e
    puts e
    next
  rescue => e
    puts "Unknown evaluation error: #{e.inspect}"
    next
  end

  puts "  => #{a} (#{a.type})"
end
