# frozen_string_literal: true
task default: [:cucumber, :spec, :rubocop]

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new
rescue LoadError
  task :spec do
    $stderr.puts 'RSpec is disabled'
  end
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new
rescue LoadError
  task :cucumber do
    $stderr.puts 'Cucumber is disabled'
  end
  task 'cucumber:travis' do
    $stderr.puts 'Cucumber is disabled'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task :rubocop do
    $stderr.puts 'RuboCop is disabled'
  end
end
