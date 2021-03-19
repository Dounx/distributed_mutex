# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "lib", "distributed_mutex", "version")

Gem::Specification.new do |s|
  s.name        = "distributed_mutex"
  s.version     = DistributedMutex::VERSION
  s.summary     = "Simple distributed locks with Redis."
  s.description = "Simple distributed locks with Redis."
  s.required_ruby_version = ">= 2.4"

  s.license = "MIT"

  s.author   = "Dounx"
  s.email    = "imdounx@gmail.com"
  s.homepage = "https://github.com/dounx/distributed_mutex"

  s.require_paths = ["lib"]
  s.files = Dir["LICENSE", "README.md", "lib/**/*"]

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/dounx/distributed_mutex/issues",
    "documentation_uri" => "https://github.com/dounx/distributed_mutex/blob/master/README.md",
    "source_code_uri" => "https://github.com/dounx/distributed_mutex"
  }
end
