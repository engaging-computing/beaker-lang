require 'test_helper'

class ParserTest < Minitest::Test
  load_parse_test('./test/integration/files/parser_simple.txt').each.with_index do |x, i|
    define_method("test_parser_simple_#{i}") do
      src, res = x
      lex = Beaker::Lexer.lex(src)
      parse = Beaker::Parser.parse(src, lex).to_s
      assert_same_parse(src, parse, res)
    end
  end
end
