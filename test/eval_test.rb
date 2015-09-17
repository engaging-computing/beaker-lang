require 'test_helper'

include FormulaFields

class EvalTest < Minitest::Test
  files = [
    ['./test/files/eval_simple.txt', 'simple'],
    ['./test/files/eval_math.txt', 'math'],
    ['./test/files/eval_array.txt', 'array'],
    ['./test/files/eval_text.txt', 'text'],
    ['./test/files/eval_location.txt', 'location'],
    ['./test/files/eval_time.txt', 'time']
  ]

  FormulaFields.stdlib.add_ns '*', NumberType.new(1)

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

  files.each do |f|
    path = f[0]
    name = f[1]
    load_parse_test(path).each.with_index do |x, i|
      define_method("test_parse_#{name}_#{i}") do
        curr_env = Environment.new(false, FormulaFields.stdlib)
        src, res = x
        lex = Lexer.lex(src)
        parse = Parser.parse(lex)
        a = parse.map { |x| x.evaluate(curr_env)}[-1].to_s
        assert_same_parse(src, a, res)
      end
    end
  end
end
