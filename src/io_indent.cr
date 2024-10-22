# a write-only IO wrapper that maintains an indentation
class IO
  class Indent < ::IO
    class MismatchedError < Exception; end

    VERSION = "0.1.0"
    getter indent : Int32 = 0
    getter chars : String = "  "
    getter io : ::IO
    @at_start_of_line : Bool = true
    @raise_on_mismatch : Bool = false

    def initialize(@io : ::IO, *, @chars = "  ", @indent = 0, @raise_on_mismatch = false)
      raise ArgumentError.new "#{self.class}: cannot wrap another #{self.class}" if @io.is_a? self.class
    end

    def read(slice : Bytes) : Nil
      raise ImplementationError.new "#{self.class} cannot read"
    end

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

    def indent(amt = 1)
      @indent += amt
    end

    def outdent(amt = 1)
      @indent -= amt
      @indent = 0 if @indent < 0
    end

    def inspect(io)
      io << "#{self.class}["
      @io.inspect(io)
      io << ",indent=#{@indent},chars=#{@chars.inspect},at_start_of_line=#{@at_start_of_line},raise_on_mismatch=#{@raise_on_mismatch}]"
    end
  end
end
