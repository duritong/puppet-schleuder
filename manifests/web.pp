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
  selinux::fcontext{
    '/var/www/schleuder-web/db/.*sqlite3':
      setype => 'httpd_sys_rw_content_t';
    '/var/www/schleuder-web/tmp(/.*)?':
      setype => 'httpd_sys_rw_content_t';
    '/var/www/schleuder-web/log(/.*)?':
      setype => 'httpd_log_t';
  } -> package{'schleuder-web':
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
    user        => 'schleuder-web',
    group       => 'schleuder-web',
  } -> file{
    '/etc/logrotate.d/schleuder-web':
      content => "/var/www/schleuder-web/*log {
  daily
  dateext
  missingok
  rotate 7
  compress
  copytruncate
  notifempty
  su schleuder-web schleuder-web
}
",
    owner     => root,
    group     => 0,
    mode      => '0644',
  }
  if $use_shorewall and $api_host != 'localhost' {
    include schleuder::web::shorewall
  }
}
