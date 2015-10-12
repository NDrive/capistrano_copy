# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "capistrano_copy"
  spec.version       = "2.0.0"
  spec.authors       = ["NDrive Dev Ops"]
  spec.email         = ["devops@ndrive.com"]

  spec.summary       = %q{This gem enables capistrano copy folder action for static apps}
  spec.description   = %q{Capistrano scm:copy action}
  spec.homepage      = "http://ndrive.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
