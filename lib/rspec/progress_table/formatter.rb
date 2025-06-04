require "rspec"
require "drb/drb"

module RSpec
  module ProgressTable
    class Formatter < RSpec::Core::Formatters::ProgressFormatter
      RSpec::Core::Formatters.register self, :example_started, :example_passed, :example_pending, :example_failed, :start, :dump_failures, :dump_pending, :dump_summary

      attr_reader :server

      def initialize(output)
        super
        DRb.start_service
        @server = if ENV["RSPEC_PROGRESS_TABLE_SERVER"]
          DRbObject.new_with_uri(ENV["RSPEC_PROGRESS_TABLE_SERVER"])
        else
          Server.start
          DRbObject.new_with_uri(DEFAULT_SERVER_URL)
        end
      end

      def start(notification)
        server.update_total(Process.pid, notification.count)
      end

      def example_started(_)
      end

      def example_passed(_)
        server.passed(Process.pid)
      end

      def example_failed(_)
        server.failed(Process.pid)
      end

      def example_pending(_)
        server.pending(Process.pid)
      end

      def dump_failures(notification)
        return if notification.failure_notifications.empty?

        server.dump(notification.fully_formatted_failed_examples)
      end

      def dump_pending(notification)
        return if notification.pending_examples.empty?

        server.dump(notification.fully_formatted_pending_examples)
      end

      def dump_summary(summary)
        server.dump(summary.fully_formatted)
      end
    end
  end
end
