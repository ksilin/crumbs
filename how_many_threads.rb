# this is a small benchmark for thread performance
# it has been motivated by a post by J.Storimer:
# http://www.jstorimer.com/blogs/workingwithcode/7970125-how-many-threads-is-too-many

# on the linux machines, we can create 10000 threads no problem. Buit what for, how is the performance?

require 'benchmark'
require 'open-uri'

require 'bigdecimal'
require 'bigdecimal/math'


def do_threaded(iterations, thread_count)

  work_per_thread = iterations / thread_count
  threads = []
  thread_count.times do
    threads << yield(work_per_thread)
  end
  threads.each(&:join) #rescue puts "failed"
end


URL = 'http://google.com/'
IO_ITERATIONS = 30

def fetch_url(thread_count)
  do_threaded(IO_ITERATIONS, thread_count) { |work|
    Thread.new { work.times { open(URL) }}
  }
end

# more latency => more threads are needed to find the 'sweet spot'
# since more threads are waiting for IO

Benchmark.bm(10) do |b|
  [1, 2, 3, 5, 6, 10, 15, 30].each do |thread_count|
    b.report("#{thread_count} threads") do
      fetch_url(thread_count)
    end
  end
end

DIGITS = 10000
CPU_ITERATIONS = 30

puts "methods: #{BigMath.methods(false)}"

include BigMath

def calc_pi(thread_count)
   do_threaded(CPU_ITERATIONS, thread_count){ |work|
     Thread.new { work.times {PI(DIGITS) }}
   }
end

Benchmark.bm(10) do |b|
  [1, 2, 3, 5, 6, 10, 15, 30].each do |thread_count|
    b.report("#{thread_count} threads") do
      calc_pi(thread_count)
    end
  end
end

# example output with MRI 2.1.0:

# user     system      total        real
# 1 threads    0.150000   0.060000   0.210000 (  6.040765)
# 2 threads    0.100000   0.040000   0.140000 (  3.454369)
# 3 threads    0.090000   0.090000   0.180000 (  2.164199)
# 5 threads    0.070000   0.020000   0.090000 (  1.529256)
# 6 threads    0.080000   0.030000   0.110000 (  1.236555)
# 10 threads   0.090000   0.000000   0.090000 (  0.906279)
# 15 threads   0.070000   0.020000   0.090000 (  0.661967)
# 30 threads   0.040000   0.040000   0.080000 (  0.485094)
# methods: [:exp, :log, :sqrt, :sin, :cos, :atan, :PI, :E]
# user     system      total        real
# 1 threads    8.390000   0.040000   8.430000 (  8.451978)
# 2 threads    8.630000   0.190000   8.820000 (  8.829903)
# 3 threads    8.670000   0.170000   8.840000 (  8.870677)
# 5 threads    8.730000   0.310000   9.040000 (  9.048933)
# 6 threads    8.580000   0.260000   8.840000 (  8.865587)
# 10 threads   8.620000   0.570000   9.190000 (  9.205575)
# 15 threads   8.920000   0.460000   9.380000 (  9.408554)
# 30 threads   9.250000   0.830000  10.080000 ( 10.115934)