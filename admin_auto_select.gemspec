# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admin_auto_select/version'

Gem::Specification.new do |spec|
  spec.name          = "active_admin_auto_select"
  spec.version       = AdminAutoSelect::VERSION
  spec.authors       = ["spyrbri"]
  spec.email         = ["spyrbri@gmail.com"]
  spec.summary       = %q{This gem helps you select a row of a column in a model with autocomplete in active admin}
  spec.description   = %q{This is an integration of select2 and active-admin}
  spec.homepage      = "https://github.com/spyrbri/active_admin_auto_select"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "active_admin"
  spec.add_dependency "select2-rails"
  spec.add_dependency "cancancan"
  spec.add_dependency "pg"
end
