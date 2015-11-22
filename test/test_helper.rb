require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'formula_fields'
require 'minitest/autorun'

def assert_same_lex(src, lex, res)
  assert lex.length == res.length,
    err_token_string_length(res.length, lex.length, src, lex, res)
  lex.zip(res).each do |x|
    l, r = x
    assert l.type == r, err_token_misimatch(l.type, r, src, lex, res)
  end
end

def assert_same_parse(src, parse, res)
  assert parse == res, err_parse_mismatch(parse, res, src)
end

def assert_same_evaluation(src, eval, res)
  if eval.type == :array
    val = FormulaFields.pack_by_type(eval.get, eval.contains)
    assert val.to_s == res, err_eval_mismatch(val.to_s, res, src)
  else
    assert eval.to_s == res, err_eval_mismatch(eval.to_s, res, src)
  end
end

def err_token_string_length(is, should, src, lex, res)
  "Token string length mismatch: should be #{should}, is #{is}" \
  "\n  String: #{src}" \
  "\n  Lexed: #{lex.map(&:type)}" \
  "\n  Should be: #{res}"
end

def err_token_misimatch(is, should, src, lex, res)
  "Token mismatch: should be #{should}, is #{is}" \
  "\n  String: #{src}" \
  "\n  Lexed: #{lex.map(&:type)}" \
  "\n  Should be: #{res}"
end

def err_parse_mismatch(is, should, src)
  'Parse mismatch:' \
  "\n  String: #{src}" \
  "\n  Parsed: #{is}" \
  "\n  Should be: #{should}"
end

def err_eval_mismatch(is, should, src)
  'Evaluation mismatch:' \
  "\n  String: #{src}" \
  "\n  Evaluated: #{is}" \
  "\n  Should be: #{should}"
end

def load_lex_test(file, is_valid = true)
  lines = []
  File.open(file, 'r') do |f|
    f.each_line do |line|
      if is_valid
        l, r = line.split('::')
        lines << [unescape(l.strip), r.strip.split(' ').map(&:to_sym)]
      else
        lines << line.strip
      end
    end
  end
  lines
end

def load_parse_test(file)
  lines = []
  File.open(file, 'r') do |f|
    f.each_line do |line|
      unless line.strip.empty? or line[0, 1] == '#'
        l, r = line.split('::')
        lines << [l.strip, r.strip]
      end
    end
  end
  lines
end

def load_eval_test(file)
  lines = []
  File.open(file, 'r') do |f|
    f.each_line do |line|
      unless line.strip.empty? or line[0, 1] == '#'
        l, r = line.split('::')
        lines << [l.strip, r.strip]
      end
    end
  end
  lines
end

def unescape(s)
  s.gsub!(/\\f/, "\f")
  s.gsub!(/\\n/, "\n")
  s.gsub!(/\\r/, "\r")
  s.gsub!(/\\t/, "\t")
  s
end
