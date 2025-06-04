require "rspec/progress_table/version"

module RSpec
  module ProgressTable
    class Error < StandardError; end

    DEFAULT_SERVER_URL = "druby://localhost:8787".freeze
  end
end

require_relative "progress_table/server"
require_relative "progress_table/formatter"
