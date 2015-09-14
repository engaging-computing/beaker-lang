require 'test_helper'

class ParserTest < Minitest::Test
  def test_valid_source_simple
    lines = load_parse_test('./test/files/parser_simple.txt')

    lines.each do |x|
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex)[0].to_s
      assert_same_parse(src, parse, res)
    end
  end

  def test_valid_source_multiline
    exprs = load_parse_multiline('./test/files/parser_multiline.txt')

    exprs.each do |x|
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex).join(';')
      assert_same_parse(src, parse, res)
    end
  end
end
