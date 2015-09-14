require 'test_helper'

class EvalTest < Minitest::Test
  load_parse_test('./test/files/eval_simple.txt').each.with_index do |x, i|
    define_method("test_parse_simple_#{i}") do
      curr_env = FormulaFields::Environment.new(false, FormulaFields.stdlib)
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex)
      a = parse.map { |x| x.evaluate(curr_env)}[-1].to_s
      assert_same_parse(src, a, res)
    end
  end
end
