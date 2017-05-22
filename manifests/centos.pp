# centos dependencies
class schleuder::centos inherits schleuder::base {
  require ::scl::ruby23
  Package['rh-ruby23-ruby-devel','rh-ruby23-rubygem-bundler'] -> Package['schleuder']
}
