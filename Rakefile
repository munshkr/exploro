require File.expand_path('../config/boot', __FILE__)
require "rake/testtask"
require 'qu/tasks'

Dir["lib/tasks/*.rake"].each { |r| import r }

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = false
end

task :default => :test
