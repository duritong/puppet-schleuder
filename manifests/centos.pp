# centos dependencies
class schleuder::centos inherits schleuder::base {
  require scl::ruby27
  Package['rh-ruby27-ruby-devel','rh-ruby27-rubygem-bundler'] -> Package['schleuder']

  if !empty($schleuder::database_config) and $schleuder::database_config['adapter'] in ['postgresql','mysql'] {
    exec { 'scl enable rh-ruby27 -- bundle exec rake db:schema:load db:migrate':
      cwd         => '/opt/schleuder',
      environment => ['RUBYLIB=/opt/schleuder/lib'],
      unless      => 'scl enable rh-ruby27 -- bundle exec ruby -e \'require \"schleuder\"; exit ActiveRecord::SchemaMigration.table_exists?\'',
      require     => File['/etc/schleuder/schleuder.yml'],
      notify      => Exec['schleuder install'],
    }
  }
}
