# benchmark IO::Indent versus the underlying IO object

require "benchmark"
require "./src/io_indent"

LINE = "0123456789" * 10

Benchmark.ips(4.seconds, 10.seconds) do |bmark|
  tmpfile = File.tempfile("io_indent_benchmark")
  bmark.report("/dev/null") { write_to File.open("/dev/null", "w") }
  bmark.report("IO::Indent") { write_to IO::Indent.new(File.open("/dev/null", "w")) }
  bmark.report("raw IO::Memory") { write_to IO::Memory.new }
  bmark.report("tmpfile") do
    write_to IO::Indent.new(tmpfile)
  end
ensure
  tmpfile.delete if tmpfile
end

def write_to(it)
  1000.times do
    it.puts LINE
  end
end
