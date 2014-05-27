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
IO_ITERATIONS = 10

def fetch_url(thread_count)
  do_threaded(IO_ITERATIONS, thread_count) { |work|
    Thread.new { work.times { open(URL) }}
  }
end

# more latency => more threads are needed to find the 'sweet spot'
# since more threads are waiting for IO

# Benchmark.bm(10) do |b|
#   [1, 2, 3, 4, 5, 6, 7, 8].each do |thread_count|
#     b.report("#{thread_count} threads") do
#       fetch_url(thread_count)
#     end
#   end
# end

DIGITS = 10000
CPU_ITERATIONS = 10

puts "methods: #{BigMath.methods(false)}"

include BigMath

def calc_pi(thread_count)
   do_threaded(CPU_ITERATIONS, thread_count){ |work|
     Thread.new { work.times {PI(DIGITS) }}
   }
end

Benchmark.bm(10) do |b|
  [1, 2, 3, 4].each do |thread_count|
    b.report("#{thread_count} threads") do
      calc_pi(thread_count)
    end
  end
end