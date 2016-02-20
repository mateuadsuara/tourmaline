# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "tourmaline"
  gem.version       = "0.1.3"
  gem.authors       = ["Mateu Adsuara"]
  gem.email         = ["mateuadsuara@gmail.com"]

  gem.summary       = %q{A configurable ruby interpreter for the command line}
  gem.homepage      = "https://github.com/mateuadsuara/tourmaline"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir        = "bin"
  gem.executables   = ["rb"]
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
end
