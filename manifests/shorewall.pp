# schleuder api daemon
class schleuder::shorewall {
  $port = $schleuder::api_port
  shorewall::rule { "net-me-${port}-tcp":
    source          => 'net',
    destination     => '$FW',
    proto           => 'tcp',
    destinationport => $port,
    order           => 240,
    action          => 'ACCEPT';
  }
  # must be ready before setting up
  Service['shorewall'] -> Exec['schleuder install']

  if $schleuder::database_config['adapter'] == 'postgresql' {
    include shorewall::rules::out::postgres
  } elsif $schleuder::database_config['adapter'] == 'mysql' {
    include shorewall::rules::out::mysql
  }

  # to refresh keys
  include shorewall::rules::out::keyserver
}
