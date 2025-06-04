require "tty/table"
require "drb/drb"
require "concurrent"

module RSpec
  module ProgressTable
    class Server
      Progress = Struct.new(:pid, :passed, :failed, :pending, :total)
      attr_reader :progresses, :output, :number_of_queue_shifted, :queue_size, :show_total
      attr_accessor :previous_rendered_lines

      def self.start(url = DEFAULT_SERVER_URL)
        DRb.start_service(url, new)
      end

      def initialize(output = $stdout)
        @progresses = Concurrent::Map.new {|m, pid|
          m[pid] = Progress.new(pid, 0, 0, 0, 0)
        }
        @previous_rendered_lines = 0
        @output = output
        @queue_size = 0
        @number_of_queue_shifted = 0
        @show_total = false
      end

      def passed(pid)
        progresses[pid].passed += 1
        render
      end

      def failed(pid)
        progresses[pid].failed += 1
        render
      end

      def pending(pid)
        progresses[pid].pending += 1
        render
      end

      def update_total(pid, n)
        progresses[pid].total = n
        @show_total = true if n > 0
      end

      def dump(s)
        puts s
        self.previous_rendered_lines = 0
      end

      def update_queue_size(n)
        @queue_size = n
      end

      def queue_shifted
        @number_of_queue_shifted += 1
      end

      def render
        table = TTY::Table.new(header: %w(PID Passed Failed Pending) + (show_total ? ["Total"] : []))
        progresses.each_value do |progress|
          table << (
            [
              progress.pid,
              RSpec::Core::Formatters::ConsoleCodes.wrap(progress.passed, :success),
              RSpec::Core::Formatters::ConsoleCodes.wrap(progress.failed, :failure),
              RSpec::Core::Formatters::ConsoleCodes.wrap(progress.pending, :pending),
            ] + (show_total ? [progress.total] : [])
          )
        end

        s = table.render(:unicode, padding: [0, 1, 0, 1], alignments: [:left, :right, :right, :right, :right])
        line_count = s.lines.count

        output.write("\e[1A" * previous_rendered_lines) if previous_rendered_lines > 0
        output.puts(s)

        unless queue_size.zero?
          r = format("%.2f", number_of_queue_shifted / queue_size.to_f * 100)
          puts "Queue: #{number_of_queue_shifted} / #{queue_size} (#{r}%)"
          line_count += 1
        end
        self.previous_rendered_lines = line_count
      end
    end
  end
end
