require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "attr_accessible_block"
  gem.homepage = "http://github.com/dmitry/attr_accessible_block"
  gem.license = "MIT"
  gem.summary = %Q{Attribute accessible block (attr_accessible with a dynamic block possibility)}
  gem.description = %Q{Convinient possibility to change attr_accessible on the fly, using definition of the required accessible attributes in a block.}
  gem.email = "dmitry.polushkin@gmail.com"
  gem.authors = ["Dmitry Polushkin"]
  gem.version = '0.2.2'
  gem.add_runtime_dependency 'activerecord', '>= 2.3.5'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "attr_accessible_block #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
