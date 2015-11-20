require 'test_helper'

include FormulaFields

class CheckTest < Minitest::Test
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
    load_parse_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res = x
        lex = Lexer.lex(src)
        parse = Parser.parse(src, lex)
        a = parse.map { |y| y.evaluate(curr_env) }[-1].to_s
        # assert_same_parse(src, a, res)
      end
    end
  end

  fail_files.each do |f|
    path = f[0]
    name = f[1]
    load_parse_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res = x
        begin
          lex = Lexer.lex(src)
          parse = Parser.parse(src, lex)
          error = ''
          parse.map { |y| y.evaluate(curr_env) }[-1].to_s
        rescue => e
          error = e.to_s
        end
        # assert_same_parse(src, error, unescape(res))
      end
    end
  end

  def setup
    FormulaFields.stdlib.add '*', NumberType.new(1)

    @env = generate_dummy_env FormulaFields.stdlib, true, 'Test',
      a: [:number],
      b: [:text],
      c: [:latitude],
      d: [:longitude],
      e: [:timestamp],
      f: [:number],
      x1: :longitude,
      x2: :longitude,
      xn: :longitude,
      y1: :latitude,
      y2: :latitude,
      y3: :latitude,
      yn: :latitude,
      t1: :timestamp,
      t2: :timestamp,
      t3: :timestamp,
      t4: :timestamp,
      t5: :timestamp,
      nn: :number
  end
end
