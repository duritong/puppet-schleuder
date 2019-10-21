forge 'https://forgeapi.puppetlabs.com'

mod 'puppetlabs-stdlib'
if !ENV['PUPPET_VERSION'].nil? && ENV['PUPPET_VERSION'].to_i < 4
  mod 'puppetlabs-concat', '~> 1.2.5'
else
  mod 'puppetlabs-concat'
end
mod 'puppet-healthcheck'
mod 'scl', :git => 'https://code.immerda.ch/immerda/puppet-modules/scl.git'
mod 'selinux', :git => 'https://code.immerda.ch/immerda/puppet-modules/selinux.git'
mod 'tor', :git => 'https://code.immerda.ch/immerda/puppet-modules/tor.git'

