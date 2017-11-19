# centos dependencies
class schleuder::centos inherits schleuder::base {
  require ::scl::ruby24
  Package['rh-ruby24-ruby-devel','rh-ruby24-rubygem-bundler'] -> Package['schleuder']
}
