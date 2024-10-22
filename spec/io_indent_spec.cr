require "./spec_helper"

describe IO::Indent do
  it "works" do
    wrapped_io = IO::Memory.new
    io = IO::Indent.new wrapped_io
    io.puts "hello"
    io.close
    wrapped_io.to_s.should eq "hello\n"
  end

  it "indents a block" do
    wrapped_io = IO::Memory.new
    io = IO::Indent.new wrapped_io
    io.puts "hello"
    io.indent do
      io.puts "indented"
    end
    io.puts "goodbye"
    io.close
    wrapped_io.to_s.should eq "hello\n  indented\ngoodbye\n"
  end

  it "manually indents" do
    wrapped_io = IO::Memory.new
    io = IO::Indent.new wrapped_io
    io.puts "hello"
    io.indent
    io.puts "indented"
    io.outdent
    io.puts "goodbye"
    io.close
    wrapped_io.to_s.should eq "hello\n  indented\ngoodbye\n"
  end

  it "doesn't allow negative indentation" do
    wrapped_io = IO::Memory.new
    io = IO::Indent.new wrapped_io
    io.puts "hello"
    io.indent
    io.puts "indented"
    io.outdent
    io.puts "goodbye"
    io.outdent
    io.puts "oops"
    io.close
    wrapped_io.to_s.should eq "hello\n  indented\ngoodbye\noops\n"
  end

  it "can start indented" do
    wrapped_io = IO::Memory.new
    io = IO::Indent.new wrapped_io, indent: 1
    io.puts "indented"
    io.outdent
    io.puts "goodbye"
    io.close
    wrapped_io.to_s.should eq "  indented\ngoodbye\n"
  end
end
