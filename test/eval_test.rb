require 'test_helper'

class EvalTest < Minitest::Test
  def test_valid_source_simple
    lines = load_parse_test('./test/files/eval_simple.txt')
    curr_env = FormulaFields::Environment.new(false, FormulaFields.stdlib)

    lines.each do |x|
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex)
      a = parse.map { |x| x.evaluate(curr_env)}[-1].to_s
      assert_same_parse(src, a, res)
    end
  end
end
