# frozen_string_literal: true

task :console do
  exec "irb -r distributed_mutex -I ./lib"
end

require "rake/testtask"

task default: :test

Rake::TestTask.new do |t|
  t.libs = %w[lib test]
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = true
  t.verbose = true
end
