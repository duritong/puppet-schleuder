# manage schleuder cli installation
class schleuder::client(
  $api_key,
  $tls_fingerprint = $schleuder_tls_fingerprint,
  $host            = 'localhost',
  $port            = '4443',
){
  # place the file first, so everything is here
  # when the package is being installed
  file{
    '/root/.schleuder-cli':
      ensure => directory,
      owner  => root,
      group  => 0,
      mode   => '0600',
  } -> concat{'/root/.schleuder-cli/schleuder-cli.yml':
    owner => root,
    group => 0,
    mode  => '0600',
  } -> package{'schleuder-cli':
    ensure => installed,
  }

  # we use a fragement to trick around the fingerprint
  # into one run
  concat::fragment{
    'schleuder-cli-header':
      target  => '/root/.schleuder-cli/schleuder-cli.yml',
      content => template('schleuder/schleuder-cli.yml.erb'),
      order   => '050';
    'schleuder-cli-fingerprint':
      target  => '/root/.schleuder-cli/schleuder-cli.yml',
      order   => '060';
  }
  if $tls_fingerprint {
    Concat::Fragment['schleuder-cli-fingerprint']{
      content => "tls_fingerprint: ${tls_fingerprint}\n"
    }
  } else {
    # trick the manually generated cert fingerprint
    # into the first run, if possible
    Concat::Fragment['schleuder-cli-fingerprint']{
      source  => '/tmp/schleuder-cli-fingerprint.tmp',
    }
    Http_conn_validator<| title == 'schleuder-api-ready' |> -> exec{'dump_schleuder_cli':
      command => "schleuder cert fingerprint | awk -F: '{ print \"tls_fingerprint:\"\$2 }' > /tmp/schleuder-cli-fingerprint.tmp",
      before  => Concat::Fragment['schleuder-cli-fingerprint'],
      onlyif  => 'bash -c "test -x /usr/bin/schleuder"',
    }
  }
}
