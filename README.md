# Beaker

Beaker is a domain-specific language designed for the [iSENSE project](https://isenseproject.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'beaker', '~> 1.3.0', git: 'https://github.com/isenseDev/beaker-lang'
```

*note: Because Beaker was designed to be integrated into iSENSE, there is no corresponding gem hosted on http://rubygems.org*

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install beaker

## Usage

Beaker is designed for integration into an existing project and as of right now lacks any significant documentation on how everything works as a whole.  In lieu of actual documentation detailing the API, below is a quick summary if you wish to integrate Beaker into your application.

#### Environments

Typically you'll want to create a new environment first. An environment is like a scope - if you are attempted to access something with an identifier, that identifier is looked up in the environment. If no match is found, the parent environment is then queried. This repeats until either a match is found or no parent exists.

An environment is created like this:

```ruby
Beaker::Environment.new(false, Beaker.stdlib)
```

`false` refers to whether or not you can write to the environment, and `Beaker.stdlib` is used as the parent environment. In previous versions of Beaker, variable assignment was supported. It no longer is, so the first argument currently doesn't do anything.

To add to an environment, call `Beaker::Environment#add(refname, object)`, where `refname` is an identifier for `object`.

#### Types

Objects in Beaker are represented as objects ending in "Type". Creating a new object can be accomplished by calling the constructor for that type with the appropriate arguments. For example:

```ruby
my_array = Beaker::ArrayType.new([50, 51, 52], :number)
```

This creates an object holding an array of numbers.

#### Parsing and Executing

To parse a Beaker expression:

```ruby
lex = Beaker::Lexer.lex(my_formula)
ast = Beaker::Parser.parse(my_formula, lex)
```

To evaluate an expression:

```ruby
val = ast.evaluate(Beaker.stdlib) # => returns a Type object
val.get # => returns the internal representation of val
```

#### Using the Language

A brief summary of how to use Beaker can be found here:

http://isenseproject.org/api/formulas_help

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/beaker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

