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
#   - 'member': list initmember address is taken and postfixed with .pub (*Default*)
#   - default: this address is taken
#   Lookup path:
#     - modules/site_schleuder/initmemberkeys/${::fqdn}/${initmemberkey}.pub
#     - modules/site_schleuder/initmemberkeys/${initmemberkey}.pub
# realname: Name of the list
#   - 'absent': Something like "${name} schleuder list" will be added" (*Default*)
#   - default: this value will be taken
# manage_alias: Wether to add an alias or not
#   - true: add alias to /etc/aliases (*Default*)
#           Note: you have to check your MTA Setup wether it supports the correct run_as User
#   - false: don't add aliases
#
define schleuder::list(
  $email                  = $name,
  $adminaddress           = undef,
  $ensure                 = present,
  $run_as                 = 'schleuder',
  $manage_run_as          = false,
  $initmember             = 'admin',
  $initmemberkey          = 'member',
  $realname               = 'absent',
  $manage_alias           = true,
  $webpassword            = 'absent',
  $webpassword_encrypted  = true,
  $webpassword_force      = false
){
  if ($webpassword != 'absent') and ($run_as != 'schleuder') {
    fail("You can't enable schleuder list ${name} on ${::fqdn} for web if it isn't running as user schleuder!")
  }

  if ($ensure == 'present') and !$adminaddress {
    fail("Must pass adminaddress to Schleuder::List[${name}]")
  }

  include ::schleuder

  $real_run_as = $run_as ? {
    'name' => $name,
    default => $run_as
  }

  $real_realname = $realname ? {
    'absent' => "${name} schleuder list",
    default => $realname
  }

  $real_initmember = $initmember ? {
    'admin' => $adminaddress,
    default => $initmember
  }

  $real_initmemberkey = $initmemberkey ? {
    'member' => $real_initmember,
    default => $initmemberkey
  }

  if $manage_run_as {
    $user_shell = $::operatingsystem ? {
      debian => '/usr/sbin/nologin',
      ubuntu => '/usr/sbin/nologin',
      default => '/sbin/nologin'
    }
    user::managed{$real_run_as:
      ensure        => $ensure,
      groups        => 'schleuder',
      manage_group  => false,
      managehome    => false,
      homedir       => "/var/schleuderlists/${name}",
      shell         => $user_shell,
      require       => User::Managed['schleuder'],
    }
  }

  file{"/var/schleuderlists/initmemberkeys/${name}_${real_initmemberkey}.pub":
    ensure  => $ensure;
  }
  exec{"manage_schleuder_list_${name}": }
  if $ensure == present {
    File["/var/schleuderlists/initmemberkeys/${name}_${real_initmemberkey}.pub"]{
      source  => [  "puppet:///modules/site_schleuder/initmemberkeys/${::fqdn}/${real_initmemberkey}.pub",
                    "puppet:///modules/site_schleuder/initmemberkeys/${real_initmemberkey}.pub" ],
      owner   => root,
      group   => schleuder,
      mode    => '0640'
    }
    $exec_require = $manage_run_as ? {
      true => [ User::Managed[$real_run_as], File["/var/schleuderlists/initmemberkeys/${name}_${real_initmemberkey}.pub",'/etc/schleuder/schleuder.conf'] ],
      default => File["/var/schleuderlists/initmemberkeys/${name}_${real_initmemberkey}.pub",'/etc/schleuder/schleuder.conf']
    }
    Exec["manage_schleuder_list_${name}"]{
      command => "${schleuder::install_dir}/contrib/newlist.rb ${name} -email ${email} -realname \"${real_realname}\" -adminaddress ${adminaddress} -initmember ${real_initmember} -initmemberkey /var/schleuderlists/initmemberkeys/${name}_${real_initmemberkey}.pub -nointeractive -mailuser ${run_as} && chown schleuder:schleuder /var/log/schleuder/schleuder.log && chmod 0660 /var/log/schleuder/schleuder.log",
      creates => "/var/schleuderlists/${name}/list.conf",
      timeout => '-1',
      before  => File['/var/log/schleuder/schleuder.log'],
      require => $exec_require,
    }
  } else {
    Exec["manage_schleuder_list_${name}"]{
      command => "rm -rf /var/schleuderlists/${name}",
      onlyif  => "test -d /var/schleuderlists/${name}",
    }
  }

  if $manage_alias {
    sendmail::mailalias{
      $name:
        ensure    => $ensure,
        recipient => "|${schleuder::install_dir}/bin/schleuder ${name}",
        require   => Exec["manage_schleuder_list_${name}"];
      "${name}-bounce":
        ensure    => $ensure,
        recipient => "|${schleuder::install_dir}/bin/schleuder ${name}",
        require   => Exec["manage_schleuder_list_${name}"];
      "${name}-sendkey":
        ensure    => $ensure,
        recipient => "|${schleuder::install_dir}/bin/schleuder ${name}",
        require   => Exec["manage_schleuder_list_${name}"];
    }
  }

  if $webpassword != 'absent' {
    webschleuder::list{$name:
      ensure              => $ensure,
      password            => $webpassword,
      password_encrypted  => $webpassword_encrypted,
      force_password      => $webpassword_force,
    }
  }
}
