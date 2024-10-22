# IO::Indent

Wrap an IO with automatic indentation.  When a character is written at the start of a line, indentation
will be added.  But only when a character is written, not after every `EOL` character.

## Installation

Add it to your `shard.yml`:

```
dependencies:
  io_indent:
    github: plambert/io_indent.cr
```

## Usage

Wrap an `IO` with a new `IO::Indent`, then write to it as normal.  Any attempt to read will raise an exception.

```crystal
io = IO::Indent.new(STDOUT)
io.puts "this is not indented"
io.indent do
  io.puts "this is indented by two spaces"
  io.indent
  io.puts "one more level of indentation"
  io.outdent
end
io.puts "back to the left"
```

This will produce:

```
this is not indented
  this is indented by two spaces
    one more level of indentation
back to the left
```

<!--
## Development

TODO: Write development instructions here

-->

## Contributing

1. Fork it (<https://github.com/plambert/io_indent.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Paul M. Lambert](https://github.com/plambert) - creator and maintainer
