require_relative "lib/ownership/version"

Gem::Specification.new do |spec|
  spec.name          = "ownership"
  spec.version       = Ownership::VERSION
  spec.summary       = "Code ownership for Rails"
  spec.homepage      = "https://github.com/ankane/ownership"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.2"
end
