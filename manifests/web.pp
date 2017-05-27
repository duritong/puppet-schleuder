# manage a schleuder-web basic installation
class schleuder::web(
  $api_key,
  $api_tls_fingerprint = getvar('::schleuder_tls_fingerprint'),
  $api_host            = 'localhost',
  $api_port            = '4443',
  $web_hostname        = 'example.org',
  $mailer_from         = 'noreply@example.org',
  $database_config     = {},
  $ruby_scl            = 'ruby23',
){
  require "::scl::${ruby_scl}"
  package{'schleuder-web':
    ensure => present,
  } -> file{
    '/var/www/schleuder-web/config/database.yml':
      content => template('schleuder/web/database.yml.erb'),
      owner   => root,
      group   => 'schleuder-web',
      mode    => '0640';
    '/var/www/schleuder-web/config/schleuder-web.yml':
      content => template('schleuder/web/schleuder-web.yml.erb'),
      owner   => root,
      group   => 'schleuder-web',
      mode    => '0640';
  } ~> exec{'setup-schleuder-web':
    command     => "scl enable rh-${ruby_scl} 'bundle exec rake db:setup RAILS_ENV=production'",
    pwd         => '/var/www/schleuder-web',
    refreshonly => true,
    user        => 'schleuder-web',
    group       => 'schleuder-web',
  }
}
