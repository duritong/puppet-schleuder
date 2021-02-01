# a small wrapper to manage init member keys and a schleuder_list
define schleuder::list (
  $ensure                        = present,
  $admin                         = undef,
  $admin_publickey               = undef,
  $admin_publickey_from_wkd      = false,
  $send_list_key                 = true,
) {
  if ($ensure == 'present') and !$admin {
    fail("Must pass adminaddress to Schleuder::List[${name}]")
  }
  $list_name = assert_type(Schleuder::Listname, $name)

  include schleuder

  schleuder_list {
    $list_name:
      ensure => $ensure,
  }
  if $ensure == present {
    if $schleuder::gpg_use_tor {
      $parts = split($list_name,'@')
      # every gnupg homedir needs this config
      file { "/var/lib/schleuder/lists/${parts[1]}/${parts[0]}/dirmngr.conf":
        source  => '/var/lib/schleuder/.gnupg/dirmngr.conf',
        owner   => 'schleuder',
        group   => 'schleuder',
        mode    => '0600',
        require => Schleuder_list[$list_name],
      }
    }

    $global_search = "${schleuder::adminkeys_path}/${admin}.pub"
    $admin_publickey_missing =
      !$admin_publickey and (file($global_search, '/dev/null') == '')

    unless $admin_publickey_missing {
      if $admin_publickey =~ /^\// {
        $real_admin_publickey = $admin_publickey
      } else {
        $real_admin_publickey = "/var/lib/schleuder/adminkeys/${name}_${admin}.pub"
        file { $real_admin_publickey:
          owner   => 'root',
          group   => 'schleuder',
          mode    => '0640',
          seltype => 'schleuder_data_t',
        }
        if !$admin_publickey {
          File[$real_admin_publickey] {
            source  => "puppet:///modules/${global_search}",
          }
        } elsif $admin_publickey =~ /^puppet:\/\// {
          File[$real_admin_publickey] {
            source => $admin_publickey,
          }
        } else {
          File[$real_admin_publickey] {
            content => $admin_publickey,
          }
        }
      }
    }

    if $admin_publickey_missing and !$admin_publickey_from_wkd {
      fail("no public key source for admin of ${list_name}")
    }

    Schleuder_list[$list_name] {
      admin_publickey          => $real_admin_publickey,
      admin_publickey_from_wkd => $admin_publickey_from_wkd,
      admin                    => $admin,
    }
    if $send_list_key {
      exec { "schleuder-cli lists send-list-key-to-subscriptions ${name}":
        environment => ['HOME=/root'],
        tag         => 'schleuder-cli-send-list-key-to-subscriptions',
        refreshonly => true,
        subscribe   => Schleuder_list[$list_name],
      }
    }
  }
}
