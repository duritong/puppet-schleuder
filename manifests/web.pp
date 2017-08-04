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
  $use_shorewall       = false,
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
    command     => "scl enable rh-${ruby_scl} 'bundle exec rake db:setup RAILS_ENV=production SCHLEUDER_TLS_FINGERPRINT=stubvalue SCHLEUDER_API_KEY=stubvalue SECRET_KEY_BASE=stubvalue SCHLEUDER_API_HOST=somehost SCHLEUDER_WEB_HOSTNAME=somehost'",
    cwd         => '/var/www/schleuder-web',
    refreshonly => true,
    onlyif      => "scl enable rh-${ruby_scl} 'bundle exec rake db:version RAILS_ENV=production SCHLEUDER_TLS_FINGERPRINT=stubvalue SCHLEUDER_API_KEY=stubvalue SECRET_KEY_BASE=stubvalue SCHLEUDER_API_HOST=somehost SCHLEUDER_WEB_HOSTNAME=somehost' | grep -E '^Current version: 0\$'",
    user        => 'schleuder-web',
    group       => 'schleuder-web',
  }
  if $use_shorewall and $api_host != 'localhost' {
    include schleuder::web::shorewall
  }
}
