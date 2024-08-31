lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/teams_card/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-teams_card'
  spec.version       = Fastlane::TeamsCard::VERSION
  spec.author        = 'Kondamon'

  spec.summary       = 'Easily alert a Microsoft Teams channel, group chat or chat via Workflows'
  spec.homepage      = "https://github.com/Kondamon/fastlane-plugin-teams_card"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.6'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
end
