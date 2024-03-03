# frozen_string_literal: true

require_relative 'lib/sidekiq_search/version'

Gem::Specification.new do |spec|
  spec.name = 'sidekiq_search'
  spec.version = SidekiqSearch::VERSION
  spec.license = 'MIT'

  spec.authors = ['Sergey Konotopov']
  spec.email = 'sergey.konotopov@gmail.com'

  spec.summary = 'Searches Sidekiq jobs by all possible parameters'
  spec.description = 'Uses Sidekiq API to get all current jobs metadata and searches by it'

  spec.homepage = 'https://github.com/kinkou/sidekiq_search'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2'

  spec.add_runtime_dependency 'sidekiq', '>= 7.2.2', '< 8'
end
