# centos dependencies
class schleuder::centos inherits schleuder::base {
  require ::scl::ruby26
  Package['rh-ruby26-ruby-devel','rh-ruby26-rubygem-bundler'] -> Package['schleuder']
}
