# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "codeaches"
  spec.version       = "1.0.0"
  spec.authors       = ["Pavan Gurudutt"]
  spec.email         = ["info@codeaches.com"]

  spec.summary       = %q{Responsive Jekyll theme for documention with built-in search.}
  spec.homepage      = "https://github.com/codeaches"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|bin|_layouts|_includes|lib|Rakefile|_sass|LICENSE|README)}i) }
  spec.executables   << 'codeaches'

  spec.add_runtime_dependency "jekyll", "~> 3.8.5"
  spec.add_runtime_dependency "rake", "~> 12.3.1"

  spec.add_development_dependency "bundler", "~> 2.0.1"
end
