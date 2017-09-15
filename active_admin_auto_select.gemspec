# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'active_admin_auto_select/version'

Gem::Specification.new do |spec|
  spec.name          = "active_admin_auto_select"
  spec.version       = AdminAutoSelect::VERSION
  spec.authors       = ["spyrbri"]
  spec.email         = ["spyrbri@gmail.com"]
  spec.summary       = %q{This gem helps you select a row of a column in a model with autocomplete in active admin}
  spec.description   = %q{This gem helps you build nice filters in Activeadmin. It combines Select2, PostgresSQL and Ajax to create an easy to use select field.}
  spec.homepage      = "https://github.com/spyrbri/active_admin_auto_select"
  spec.license       = "MIT"
  spec.files         = `git ls-files`.split("\n")
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "select2-rails", "3.5.2"
  spec.add_dependency "underscore-rails"
  spec.add_dependency "pg"
end
