require 'test_helper'

include FormulaFields

class EvalTest < Minitest::Test
  pass_files = [
    ['./test/integration/files/eval_simple.txt', 'simple'],
    ['./test/integration/files/eval_math.txt', 'math'],
    ['./test/integration/files/eval_number.txt', 'number'],
    ['./test/integration/files/eval_array.txt', 'array'],
    ['./test/integration/files/eval_bool.txt', 'bool'],
    ['./test/integration/files/eval_text.txt', 'text'],
    ['./test/integration/files/eval_location.txt', 'location'],
    ['./test/integration/files/eval_time.txt', 'time']
  ]

  fail_files = [
    ['./test/integration/files/eval_fail.txt', 'fail']
  ]

  pass_files.each do |f|
    path = f[0]
    name = f[1]
    load_eval_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res = x
        lex = Lexer.lex(src)
        parse = Parser.parse(src, lex)
        ev = parse.evaluate(curr_env)
        assert_same_evaluation(src, ev, res)
      end
    end
  end

  fail_files.each do |f|
    path = f[0]
    name = f[1]
    load_eval_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res = x
        begin
          lex = Lexer.lex(src)
          parse = Parser.parse(src, lex)
          error = ''
          parse.evaluate(curr_env)
        rescue => e
          error = e.to_s
        end
        #assert_same_error(src, error, unescape(res))
      end
    end
  end

  def setup
    FormulaFields.stdlib.add '*', NumberType.new(1)

    @env = Environment.new(true, FormulaFields.stdlib)
    @env.add 'Test',
      'a' => ArrayType.new([1, 2, 3, 4, 5], :number, 1),
      'b' => ArrayType.new(['a', 'b', 'c'], :text, 1),
      'c' => ArrayType.new([30, 60, 90, 120, 150], :latitude, 1),
      'd' => ArrayType.new([45, 90, 135, 180, 225, 270], :longitude, 1),
      'e' => ArrayType.new([
        DateTime.new(2015, 1, 1, 1, 1, 1),
        DateTime.new(2016, 1, 1, 1, 1, 1),
        DateTime.new(2017, 1, 1, 1, 1, 1),
        DateTime.new(2018, 1, 1, 1, 1, 1),
        DateTime.new(2019, 1, 1, 1, 1, 1)
      ], :timestamp, 1),
      'f' => ArrayType.new([1, 2, 3, 4, nil], :number, 1),
      'x1' => LongitudeType.new(75),
      'x2' => LongitudeType.new(0),
      'xn' => LongitudeType.new(nil),
      'y1' => LatitudeType.new(0),
      'y2' => LatitudeType.new(90),
      'y3' => LatitudeType.new(75),
      'yn' => LatitudeType.new(nil),
      't1' => TimestampType.new('2015/8/24 9:31:00'),
      't2' => TimestampType.new('2015/8/24 17:31:00'),
      't3' => TimestampType.new('2015/8/25 9:31:00'),
      't4' => TimestampType.new('2015/8/25 17:31:00'),
      't5' => TimestampType.new('2015/8/26 13:41:32'),
      'nn' => NumberType.new(nil)
  end
end
