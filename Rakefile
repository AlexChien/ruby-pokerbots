require 'rake/testtask'
require './lib/poker'

Dir["./lib/tasks/**/*.rake"].sort.each { |ext| load ext }

Rake::TestTask.new do |t|
    t.pattern = "spec/*_spec.rb"
end

desc "Console mode"
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :default => :test

