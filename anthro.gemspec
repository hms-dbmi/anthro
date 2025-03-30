# frozen_string_literal: true

require_relative "lib/anthro/version"

Gem::Specification.new do |spec|
  spec.name = "anthro"
  spec.version = Anthro::VERSION
  spec.authors = ["Joon Lee"]
  spec.email = ["seouri@gmail.com"]

  spec.summary       = "Calculate anthropometric z-scores and percentiles using WHO and CDC 2000 growth charts."
  spec.description   = "A Ruby gem for calculating anthropometric z-scores and percentiles based on the WHO and CDC 2000 growth chart data."
  spec.homepage      = "https://github.com/hms-dbmi/anthro"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bigdecimal", "~> 3.1"
  spec.add_dependency "distribution", "~> 0.8"
  spec.add_dependency "prime", "~> 0.1.3"
  spec.add_development_dependency "bundler", "~> 2.6"
  spec.add_development_dependency "irb", "~> 1.15", ">= 1.15.1"
  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rubocop", "~> 1.74"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
