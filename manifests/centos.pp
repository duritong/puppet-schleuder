# centos dependencies
class schleuder::centos inherits schleuder::base {
  require scl::ruby27
  Package['rh-ruby27-ruby-devel','rh-ruby27-rubygem-bundler'] -> Package['schleuder']
}
