# manage a schleuder-web basic installation
class schleuder::web(
  String
    $api_key,
  String
    $api_tls_fingerprint = getvar('::schleuder_tls_fingerprint'),
  String
    $api_host            = 'localhost',
  Integer
    $api_port            = 4443,
  String
    $web_hostname        = 'example.org',
  String
    $mailer_from         = 'noreply@example.org',
  Hash
    $database_config     = {},
  Pattern[/^ruby\d+/]
    $ruby_scl            = 'ruby26',
  Boolean
    $use_shorewall       = false,
  Optional[Array[String]]
    $superadmins         = [],
){
  require "scl::${ruby_scl}"
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
