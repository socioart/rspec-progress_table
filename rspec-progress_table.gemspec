require_relative "lib/rspec/progress_table/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-progress_table"
  spec.version       = Rspec::ProgressTable::VERSION
  spec.authors       = ["labocho"]
  spec.email         = ["labocho@penguinlab.jp"]

  spec.summary       = "RSpec formatter that shows progress in a table format."
  spec.description   = "RSpec formatter that shows progress in a table format."
  spec.homepage      = "https://gitub.com/socioart/rspec-progress_table"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitub.com/socioart/rspec-progress_table"
  spec.metadata["changelog_uri"] = "https://github.com/socioart/rspec-progress_table/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r(^exe/)) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.3"
  spec.add_dependency "tty-table", "~> 0.12.0"
end
