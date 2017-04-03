# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yinx_st/version'

Gem::Specification.new do |spec|
  spec.name          = "yinx_st"
  spec.version       = YinxSt::VERSION
  spec.authors       = ["ken"]
  spec.email         = ["block24block@gmail.com"]

  spec.summary       = %q{Statistics for yinx_sql}
  spec.homepage      = "https://github.com/turnon/yinx_st"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "yinx", "~> 0.1.0"
  spec.add_dependency "yinx_sql", "~> 0.1.2"
  spec.add_dependency "my_chartkick", "~> 0.1.0"
  spec.add_dependency "time_seq", "~> 0.1.0"
end
