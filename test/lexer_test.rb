require 'test_helper'

class LexerTest < Minitest::Test
  def test_valid_source_simple
    lines = load_lex_test('./test/files/lexer_simple.txt')

    lines.each do |x|
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      assert_same_lex(src, lex, res)
    end
  end

  def test_valid_source_greedy
    lines = load_lex_test('./test/files/lexer_greedy.txt')

    lines.each do |x|
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      assert_same_lex(src, lex, res)
    end
  end

  def test_invalid_source
    failed = false
    lines = load_lex_test('./test/files/lexer_incorrect.txt', false)
    lines.each do |x|
      begin
        FormulaFields::Lexer.lex(x)
        assert false, "Should not have been able to lex '#{x}'"
      rescue RLTK::LexingError
        failed = true
      rescue => e
        assert false, "Raised incorrect exception when parsing '#{x}': #{e.class}"
      end
      assert failed, "Should have raised an exception when lexing '#{x}'"
    end
  end
end
