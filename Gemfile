source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 7.0']
end

gem 'rake'
gem 'librarian-puppet', '>=0.9.10'
gem 'puppet',  puppetversion
gem 'base32'
gem 'puppet-lint', '>=0.3.2'
gem 'puppetlabs_spec_helper', '>=0.2.0'
