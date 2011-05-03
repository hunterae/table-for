require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "table-for"
    gemspec.summary = ""
    gemspec.description = ""
    gemspec.email = "hunterae@gmail.com"
    gemspec.homepage = "http://github.com/hunterae/table-for"
    gemspec.authors = ["Andrew Hunter"]
    gemspec.files =  FileList["[A-Z]*", "{lib,spec,app,rails}/**/*"] - FileList["**/*.log", "Gemfile", "Gemfile.lock"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end