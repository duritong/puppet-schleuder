forge 'https://forgeapi.puppetlabs.com'

mod 'puppetlabs-stdlib'
if !ENV['PUPPET_VERSION'].nil? && ENV['PUPPET_VERSION'].to_i < 4
  mod 'puppetlabs-concat', '~> 1.2.5'
else
  mod 'puppetlabs-concat'
end
mod 'puppet-healthcheck'
mod 'scl', :git => 'https://git-ipuppet.immerda.ch/module-scl'
mod 'selinux', :git => 'https://git-ipuppet.immerda.ch/module-selinux'
mod 'tor', :git => 'https://git-ipuppet.immerda.ch/module-tor'

