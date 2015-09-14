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

  #def test_invalid_source
  #  failed = false
  #  snips = ['`', '~', '@', '#', '$', '|', '&', ';', ':', '{', '}', '\\', '?', '"\"', "'\\'"]
  #  snips.each do |x|
  #    begin
  #      lex = FormulaFields::Lexer.lex(x)
  #      assert false, "Should not have been able to lex '#{x}'"
  #    rescue RLTK::LexingError
  #      failed = true
  #    rescue => e
  #      assert false, "Raised incorrect exception when parsing '#{x}': #{e.class}"
  #    end
  #    assert failed, "Should have raised an exception when lexing '#{x}'"
  #  end
  #end
  
end
