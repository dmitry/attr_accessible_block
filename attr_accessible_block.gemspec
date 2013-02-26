# -*- encoding: utf-8 -*-
require File.expand_path('../lib/attr_accessible_block/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dmitry Polushkin"]
  gem.email         = ["dmitry.polushkin@gmail.com"]
  gem.description   = %q{Set attr_accessible attributes on runtime.}
  gem.summary       = %q{Bonus power attr_accessible on steroids with possibility to change accessibles on the fly.}
  gem.homepage      = "https://github.com/dmitry/attr_accessible_block"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "attr_accessible_block"
  gem.require_paths = ["lib"]
  gem.version       = AttrAccessibleBlock::VERSION

  gem.add_dependency "activemodel", '>= 3.2'
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
