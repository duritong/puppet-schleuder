# schleuder api daemon
class schleuder::web::shorewall {
  $port = $schleuder::web::api_port
  shorewall::rule { "me-net-schleuder-api-${port}-tcp":
    source          => '$FW',
    destination     => 'net',
    proto           => 'tcp',
    destinationport => $port,
    order           => 240,
    action          => 'ACCEPT';
  }
  # must be ready before setting up
  Service['shorewall'] -> Exec['setup-schleuder-web']

  if $schleuder::web::database_config['adapter'] == 'postgresql' {
    include shorewall::rules::out::postgres
  } elsif $schleuder::web::database_config['adapter'] == 'mysql' {
    include shorewall::rules::out::mysql
  }
}
