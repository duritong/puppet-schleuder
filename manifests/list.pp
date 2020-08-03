# a small wrapper to manage init member keys and a schleuder_list
define schleuder::list(
  $ensure          = present,
  $admin           = undef,
  $admin_publickey = undef,
  $send_list_key   = true,
){
  if ($ensure == 'present') and !$admin {
    fail("Must pass adminaddress to Schleuder::List[${name}]")
  }

  include schleuder

  schleuder_list{
    $name:
      ensure => $ensure,
  }
  if $ensure == present {
    if $schleuder::gpg_use_tor {
      $parts = split($name,'@')
      # every gnupg homedir needs this config
      file{"/var/lib/schleuder/lists/${parts[1]}/${parts[0]}/dirmngr.conf":
        source  => '/var/lib/schleuder/.gnupg/dirmngr.conf',
        owner   => 'schleuder',
        group   => 'schleuder',
        mode    => '0600',
        require => Schleuder_list[$name],
      }
    }

    if $admin_publickey and $admin_publickey =~ /^\// {
      $real_admin_publickey = $admin_publickey
    } else {
      $real_admin_publickey = "/var/lib/schleuder/adminkeys/${name}_${admin}.pub"
      file{$real_admin_publickey:
        owner   => 'root',
        group   => 'schleuder',
        mode    => '0640',
        seltype => 'schleuder_data_t',
      }
      if !$admin_publickey {
        File[$real_admin_publickey]{
          source  => "puppet:///${schleuder::adminkeys_path}/${admin}.pub",
        }
      } elsif $admin_publickey =~ /^puppet:\/\// {
        File[$real_admin_publickey]{
          source => $admin_publickey,
        }
      } else {
        File[$real_admin_publickey]{
          content => $admin_publickey,
        }
      }
    }
    Schleuder_list[$name]{
      admin_publickey => $real_admin_publickey,
      admin           => $admin,
    }
    if $send_list_key {
      exec{"schleuder-cli lists send-list-key-to-subscriptions ${name}":
        environment => ['HOME=/root'],
        tag         => 'schleuder-cli-send-list-key-to-subscriptions',
        refreshonly => true,
        subscribe   => Schleuder_list[$name],
      }
    }
  }
}
