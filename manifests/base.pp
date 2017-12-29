# manage a schleuder installation
class schleuder::base {
  package{'schleuder':
    ensure => installed,
  } -> file{'/etc/schleuder/schleuder.yml':
    content => template('schleuder/schleuder.yml.erb'),
    owner   => 'root',
    group   => 'schleuder',
    mode    => '0640',
    seltype => 'schleuder_data_t',
  } ~> exec{'schleuder install':
    refreshonly => true,
    notify      => Service['schleuder-api-daemon'],
  } -> file{
    ['/etc/schleuder/schleuder-certificate.pem',
    '/etc/schleuder/schleuder-private-key.pem']:
      seltype => 'schleuder_data_t',
      owner   => root,
      group   => 'schleuder',
      mode    => '0640';
  } ~> service{'schleuder-api-daemon':
    ensure => running,
    enable => true,
  } -> http_conn_validator { 'schleuder-api-ready':
    host        => $schleuder::api_host,
    port        => $schleuder::api_port,
    use_ssl     => true,
    test_url    => '/status.json',
    # api likely uses custom certs
    verify_peer => false,
  }

  file{'/var/lib/schleuder/adminkeys':
    ensure  => directory,
    owner   => 'root',
    group   => 'schleuder',
    mode    => '0640',
    seltype => 'schleuder_data_t',
    purge   => true,
    force   => true,
    recurse => true,
    require => Package['schleuder'],
  }

  if $schleuder::cli_api_key {
    class{'::schleuder::client':
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
        seltype => 'schleuder_data_t',
        require => Exec['schleuder install'],
        before  => Service['schleuder-api-daemon'],
    }
  }
  # export data as fragment, so it can be collected somewhere else
  if $schleuder::tls_fingerprint and $schleuder::export_tls_fingerprint {
    @@concat::fragment{
      "schleuder-tls-fingerprint-${facts['fqdn']}":
        target  => '/tmp/some_path_for_tls_fingerprint',
        content => $schleuder::tls_fingerprint,
        order   => '050';
    }
  }
  if $schleuder::web_api_key and $schleuder::export_web_api_key {
    @@concat::fragment{
      "schleuder-web-api-key-${facts['fqdn']}":
        target  => '/tmp/some_path_for_web_api_key',
        content => $schleuder::web_api_key,
        order   => '050';
    }
  }

  if $schleuder::gpg_use_tor {
    include ::tor::daemon
    file{
      '/var/lib/schleuder/.gnupg':
        ensure  => directory,
        owner   => 'schleuder',
        group   => 'schleuder',
        mode    => '0600',
        require => Package['schleuder'];
      '/var/lib/schleuder/.gnupg/dirmngr.conf':
        content => template('schleuder/dirmngr.conf.erb'),
        owner   => 'schleuder',
        group   => 'schleuder',
        mode    => '0600',
        require => Service['tor'],
    }
  }
}
