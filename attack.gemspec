# -*- encoding: utf-8 -*-
require File.expand_path('../lib/attack/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "attack"
  s.version = Attack::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Renan Tomal Fernandes", "Marcos Piccinini"]
  s.email = ["talk@fireho.com"]
  s.homepage = "http://rubygems.org/gems/attack"
  s.summary = "Attach (K) events!"
  s.description = "This gem provides a nice way to attack, attack events. Rails ready."
  s.license = "MIT"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "attack"

  s.add_dependency "railties", ">= 3.0", "< 5.0"
  #s.add_dependency "thor", ">= 0.14", "< 2.0"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_path = 'lib'
end
