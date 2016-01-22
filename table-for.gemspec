# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'table_for/version'

Gem::Specification.new do |spec|
  spec.name          = "table-for"
  spec.version       = TableFor::VERSION
  spec.authors       = ["Andrew Hunter"]
  spec.email         = ["hunterae@gmail.com"]
  spec.summary       = %q{table-for is a table builder for an array of objects, easily allowing overriding of how any aspect of the table is generated}
  spec.description   = %q{table-for is a table builder for an array of objects, easily allowing overriding of how any aspect of the table is generated}
  spec.homepage      = "http://github.com/hunterae/table-for"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 3.0.0"
  spec.add_dependency "with_template", "~> 0.2.0"

  spec.add_development_dependency "rspec-rails", ">= 2.0.0.beta.20"
  spec.add_development_dependency "mocha", "0.10.3"
  spec.add_development_dependency "xml-simple", "1.1.1"
  spec.add_development_dependency "supermodel"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "with_model"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "nokogiri"
end
