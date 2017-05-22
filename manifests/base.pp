# manage a schleuder installation
class schleuder::base {
  package{'schleuder':
    ensure => installed,
  } -> file{'/etc/schleuder/schleuder.yml':
    content => template('schleuder/schleuder.yml.erb'),
    owner   => 'root',
    group   => 'schleuder',
    mode    => '0640',
  } ~> exec{'schleuder install':
    refreshonly => true,
    notify      => Service['schleuder-api-daemon'],
  } -> file{
    ['/etc/schleuder/schleuder-certificate.pem',
    '/etc/schleuder/schleuder-private-key.pem']:
      owner => root,
      group => 'schleuder',
      mode  => '0640';
  } ~> service{'schleuder-api-daemon':
    ensure => running,
    enable => true,
  } -> http_conn_validator { 'schleuder-api-ready':
    host          => $schleuder::api_host,
    port          => $schleuder::api_port,
    use_ssl       => true,
    test_url      => '/status.json',
    # api likely uses custom certs
    verify_peer   => false,
    # at the moment api requires always
    # authentication
    expected_code => 401,
  }

  file{'/var/lib/schleuder/adminkeys':
    ensure  => directory,
    owner   => 'root',
    group   => 'schleuder',
    mode    => '0640',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['schleuder'],
  }

  if $schleuder::cli_api_key {
    class{'schleuder::client':
      api_key         => $schleuder::cli_api_key,
      tls_fingerprint => $schleuder::tls_fingerprint,
      host            => $schleuder::api_host,
      port            => $schleuder::api_port,
    }
    # make sure we only setup the cli once schleuder itself is done
    Http_conn_validator['schleuder-api-ready'] -> File['/root/.schleuder-cli']
  }

  if empty($schleuder::database_config) or $schleuder::database_config['adapter'] == 'sqlite3' {
    if empty($schleuder::database_config) or !$schleuder::database_config['database'] {
      $db_file = '/var/lib/schleuder/db.sqlite'
    } else {
      $db_file = $schleuder::database_config['database']
    }
    file{
      $db_file:
        owner   => 'schleuder',
        group   => 'schleuder',
        mode    => '0640',
        require => Exec['schleuder install'],
        before  => Service['schleuder-api-daemon'],
    }
  }
}
