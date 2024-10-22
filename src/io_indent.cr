# a write-only IO wrapper that maintains an indentation
class IO
  # A `IO::Indent` is a write-only wrapper over an `IO` object that automatically
  # inserts indentation before writing the first character on each line.
  #
  # ```
  # io = IO::Indent.new STDOUT
  # io.puts "this is not indented"
  # io.indent do
  #   io.puts "this is indented"
  #   io.indent(2)
  #   io.puts "this is indented six spaces"
  #   io.outdent(2) # or you can write io.indent(-2)
  # end
  # ```
  #
  class Indent < ::IO
    # This `Exception` is raised if `#raise_on_mismatch` is `true` and an `#indent(&)` block
    # returns with the indent level not set to the expected value.  For example, if
    # inside the block `io.indent(1)` is called without a corresponding `io.outdent(1)`
    # method call to return to the expected level.
    class MismatchedError < Exception; end

    VERSION      = "0.1.0"
    LINE_PATTERN = %r{([^\n]+)|\n}

    # The current indentation level
    getter indent : Int32 = 0

    # Each level of indentation is expressed with this string
    getter chars : String = "  "

    # The wrapped `IO` object that is written to
    getter io : ::IO

    # If true, a `IO::Indent::MismatchedError` is raised if an `#indent(&)` block returns
    # with an unexpected indentation level.
    property? raise_on_mismatch = false

    @at_start_of_line : Bool = true

    # Create a new `IO::Indent` object
    def initialize(@io : ::IO, *, @chars = "  ", @indent = 0, @raise_on_mismatch = false)
      raise ArgumentError.new "#{self.class}: cannot wrap another #{self.class}" if @io.is_a? self.class
    end

    # :nodoc:
    def read(slice : Bytes) : Nil
      raise ImplementationError.new "#{self.class} cannot read"
    end

    # Writes the given object into this `IO`.
    # This ends up calling `to_s(io)` on the object.
    #
    # ```
    # io = IO::Memory.new
    # io << 1
    # io << '-'
    # io << "Crystal"
    # io.to_s # => "1-Crystal"
    # ```
    def <<(obj) : self
      case obj
      when String
        write obj
      else
        obj.to_s self
      end
      self
    end

    # Write Bytes to the wrapped `IO` object, indenting when starting a new line
    def write(slice : Bytes) : Nil
      str = String.new(slice)
      str.each_char do |char|
        case char
        when '\n'
          @at_start_of_line = true
        else
          if @at_start_of_line
            @io << @chars * @indent
            @at_start_of_line = false
          end
        end
        @io << char
      end
    end

    # :nodoc:
    def write(str : String) : Nil
      if str.single_byte_optimizable?
        str.each_byte do |byte|
          if byte == '\n'.ord
            @at_start_of_line = true
          elsif @at_start_of_line
            @indent.times { @io << @chars }
            @at_start_of_line = false
          end
          @io << byte.chr
        end
      else
        pos = 0

        while match = LINE_PATTERN.match(str, pos)
          pos = match.end
          if match[1]?
            if @at_start_of_line
              @io << @chars * @indent
              @at_start_of_line = false
            end
            @io << match[1]
          else
            @io << '\n'
            @at_start_of_line = true
          end
        end
      end
    end

    # Raise the indent level and yield the `IO::Indent` object to the block
    def indent(&)
      saved_indent = @indent
      begin
        @indent += 1
        yield self
      ensure
        @indent -= 1
        raise IO::Indent::MismatchedError.new "indent is #{@indent} but expected #{saved_indent}" if @raise_on_mismatch && @indent != saved_indent
      end
    end

    # Raise the indentation level by the given amount
    def indent(amt = 1)
      @indent += amt
    end

    # Lower the indentation level by the given amount
    def outdent(amt = 1)
      @indent -= amt
      @indent = 0 if @indent < 0
    end

    # :inherit:
    def inspect(io)
      io << "#{self.class}["
      @io.inspect(io)
      io << ",indent=#{@indent},chars=#{@chars.inspect},at_start_of_line=#{@at_start_of_line},raise_on_mismatch=#{@raise_on_mismatch}]"
    end
  end
end
