require 'test_helper'

class ParserTest < Minitest::Test
  load_parse_test('./test/files/parser_simple.txt').each.with_index do |x, i|
    define_method("test_parser_simple_#{i}") do
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex)[0].to_s
      assert_same_parse(src, parse, res)
    end
  end

  load_parse_multiline('./test/files/parser_multiline.txt').each.with_index do |x, i|
    define_method("test_parser_multiline_#{i}") do
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      parse = FormulaFields::Parser.parse(lex).join(';')
      assert_same_parse(src, parse, res)
    end
  end
end
