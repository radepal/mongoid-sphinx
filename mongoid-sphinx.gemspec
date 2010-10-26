# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "mongoid_sphinx/version"

Gem::Specification.new do |s|
  s.name        = "mongoid-sphinx"
  s.version     = MongoidSphinx::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Hodgson"]
  s.email       = ["mhodgson@scenario4.com"]
  s.homepage    = "http://github.com/mhodgson/mongoid-sphinx"
  s.summary     = "A full text indexing extension for MongoDB using Sphinx and Mongoid."
  s.description = "A full text indexing extension for MongoDB using Sphinx and Mongoid."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("mongoid", ["~> 2.0.0.beta.19"])
  s.add_dependency("riddle", ["~> 1.1.0"])
  s.add_dependency("escape_utils", ["~> 0.1.9"])
  s.files        = Dir.glob("lib/**/*") + %w(README.rdoc)
  s.require_path = 'lib'
end
