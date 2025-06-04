module RSpec
  module ProgressTable
    module TestQueue
      class << self
        attr_reader :server

        def use(server_url = DEFAULT_SERVER_URL)
          # Example 名と処理時間の表示を抑制
          RSpec::Core::QueueRunner.include(
            Module.new do
              def print(s)
                # nop
              end

              def puts(s)
                # nop
              end
            end,
          )

          RSpec::ProgressTable::Server.start(server_url)
          @server = DRbObject.new_with_uri(server_url)
          ENV["RSPEC_PROGRESS_TABLE_SERVER"] = server_url
        end
      end

      module Runner
        module PrependingMethods
          def prepare(concurrency)
            ::RSpec::ProgressTable::TestQueue.server.update_queue_size(@queue.size)
            @queue.singleton_class.prepend(
              Module.new {
                def shift
                  ::RSpec::ProgressTable::TestQueue.server.queue_shifted
                  super
                end
              },
            )
            super
          end
        end

        def self.included(base)
          base.class_eval do
            prepend PrependingMethods
          end
        end
      end
    end
  end
end
