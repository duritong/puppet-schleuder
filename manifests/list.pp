# run_as:
#   - 'name': use the name var to determine the actual user
#   - default: set permission for schleuder to this user. Default is schleuder.
# manage_run_as: wether to manage the run_as user
#   - false, don't do anything (*Default*)
#   - true, create run_as user and put it into the group schleuder
# email: the email address of the list
# adminaddress: list admin
# initmember: initial member of the list
#   - 'admin': list admin is taken (*Default*)
#   - default: this address is taken
# initmemberkey: public key of the initial admin
#   Lookup path:
#     - files/schleuder/initmemberkeys/${fqdn}/${initmemberkey}.pub
#     - files/schleuder/initmemberkeys/${initmemberkey}.pub
# realname: Name of the list
#   - 'absent': Something like "${name} schleuder list" will be added" (*Default*)
#   - default: this value will be taken 
# manage_alias: Wether to add an alias or not
#   - true: add alias to /etc/aliases (*Default*)
#           Note: you have to check your MTA Setup wether it supports the correct run_as User
#   - false: don't add aliases
#   
define schleuder::list(
  $ensure = present,
  $run_as = 'schleuder',
  $manage_run_as = false,
  $email,
  $adminaddress,
  $initmember = 'admin',
  $initmemberkey,
  $realname = 'absent',
  $manage_alias = true
){
  include ::schleuder

  $real_run_as = $run_as ? {
    'name' => $name,
    default => $run_as
  }

  $real_realname = $realname ? {
    'absent' => "${name} schleuder list",
    default => $realname
  }

  if $schleuder_install_dir == '' {
    $schleuder_install_dir  = '/opt/schleuder'
  }

  $real_initmember = $initmember ? {
    'admin' => $adminaddress,
    default => $initmember
  }

  if $manage_run_as {
    user::managed{$real_run_as:
      ensure => $ensure,
      groups => 'schleuder',
      manage_group => false,
      manage_home => false,
      homedir => "/var/schleuderlists/${name}",
      shell => $operatingsystem ? {
        debian => '/usr/sbin/nologin',
        ubuntu => '/usr/sbin/nologin',
        default => '/sbin/nologin'
      },
      require => User::Managed['schleuder'],
    }
  }

  file{"/var/schleuderlists/init_public_keys/${name}_${initmemberkey}.pub":
    source => [ "puppet://$server/files/schleuder/init_public_keys/${fqdn}/${initmemberkey}.pub",
                "puppet://$server/files/schleuder/init_public_keys/${initmemberkey}.pub" ],
    ensure => $ensure,
    owner => root, group => schleuder, mode => 0640;
  }

  exec{"manage_schleuder_list_${name}": }
  if $ensure == present {
    Exec["manage_schleuder_list_${name}"]{
      command => "${schleuder_install_dir}/contrib/newlist.rb ${name} -email ${email} -realname \"${real_realname}\" -adminaddress ${adminaddress} -initmember ${real_initmember} -initmemberkey /var/schleuderlists/init_public_keys/${name}_${initmemberkey}.pub -nointeractive -mailuser ${run_as}",
      require => File["/var/schleuderlists/init_public_keys/${name}_${initmemberkey}.pub"],
      creates => "/var/schleuderlists/${name}/list.conf",
    }
  } else {
    Exec["manage_schleuder_list_${name}"}[
      command => "rm -rf /var/schleuderlists/${name}",
      onlyif => "test -d /var/schleuderlists/${name}",
    } 
  }

  if $manage_alias {
    sendmail::mailalias{$name:
      ensure => $ensure,
      recipient => "|${schleuder_install_dir}/bin/schleuder ${name}",
    }
  }
}
