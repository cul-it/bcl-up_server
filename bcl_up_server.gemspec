# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bcl_up_server/version'

Gem::Specification.new do |spec|
  spec.authors       = ["Shinwoo Kim, Jeremy Duncan"]
  spec.email         = ["sk274@cornell.edu, jpd294@cornell.edu"]
  spec.description   = "A rails engine with questioning authority gem installed to serve as an authority search server with normalized results."
  spec.summary       = "BCL-UP Server"

  spec.homepage      = "http://github.com/cul-it/bcl-up_server"

  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.name          = "bcl_up_server"
  spec.require_paths = ["lib"]
  spec.version       = BclUpServer::VERSION

  spec.license       = 'Apache-2.0'

  # Note: rails does not follow sem-ver conventions, it's
  # minor version releases can include breaking changes; see
  # http://guides.rubyonrails.org/maintenance_policy.html
  spec.add_dependency 'rails', '~> 7.0'
  spec.add_dependency 'useragent'

  # Required gems for QA and linked data access
  spec.add_development_dependency 'qa', '~> 5.14'# questioning_authority
  spec.add_development_dependency 'linkeddata'

  # Produces dashboard charts on monitor status page
  spec.add_dependency 'gruff'

  spec.add_development_dependency 'better_errors' # provide debugging command line in
  spec.add_development_dependency 'binding_of_caller' # provides deep stack info used by better_errors
  spec.add_development_dependency 'bixby', '~> 5.0' # rubocop styleguide
  # spec.add_development_dependency "capybara", '~> 3.29'
  # spec.add_development_dependency 'capybara-maleficent', '~> 0.3.0'
  # spec.add_development_dependency 'chromedriver-helper', '~> 2.1'
  spec.add_development_dependency 'deprecation'
  spec.add_development_dependency 'engine_cart', '~> 2.6'
  spec.add_development_dependency "factory_bot", '~> 4.4'
  spec.add_development_dependency 'i18n-tasks'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rails-controller-testing', '~> 1'
  spec.add_development_dependency 'rspec-activemodel-mocks', '~> 1.0'
  spec.add_development_dependency 'rspec-its', '~> 1.1'
  spec.add_development_dependency 'rspec-rails', '~> 6.0'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'webdrivers', '~> 4.4'
  spec.add_development_dependency 'webmock'

  ########################################################
  # Temporarily pinned dependencies. INCLUDE EXPLANATIONS.
  #
  # Pin sass-rails to 5.x because rails 5.x apps have this same dependency in their generated Gemfiles
  spec.add_dependency 'sass-rails', '~> 5.0'
end
