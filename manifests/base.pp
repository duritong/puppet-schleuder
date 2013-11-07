# manage basic things of schleuder
class schleuder::base {
  include rubygems::tmail
  include rubygems::gpgme

  if $schleuder::enable_highline {
    include rubygems::highline
  }

  $user_shell = $::operatingsystem ? {
    debian => '/usr/sbin/nologin',
    ubuntu => '/usr/sbin/nologin',
    default => '/sbin/nologin'
  }
  user::managed{'schleuder':
    name_comment  => 'schleuder user',
    managehome    => false,
    homedir       => '/var/schleuderlists',
    shell         => $user_shell,
  }

  git::clone{'schleuder':
    git_repo        => 'git://git.immerda.ch/schleuder.git',
    projectroot     => $schleuder::install_dir,
    cloneddir_group => 'schleuder',
    require         => [ User::Managed['schleuder'], Package['tmail'], Package['ruby-gpgme'] ],
  }

  file{
    ["${schleuder::install_dir}/bin/schleuder", "${schleuder::install_dir}/contrib/newlist.rb" ]:
      require => Git::Clone['schleuder'],
      owner   => root,
      group   => 'schleuder',
      mode    => '0750';
    [ '/etc/schleuder', '/var/schleuderlists', '/var/schleuderlists/initmemberkeys' ]:
      ensure  => directory,
      require => [ User::Managed['schleuder'], Git::Clone['schleuder'] ],
      owner   => root,
      group   => schleuder,
      mode    => '0640';
    '/etc/schleuder/default-list.conf':
      source  => [  "puppet:///modules/site_schleuder/config/${::fqdn}/default-list.conf",
                    'puppet:///modules/site_schleuder/config/default-list.conf',
                    'puppet:///modules/schleuder/config/default-list.conf' ],
      owner   => root,
      group   => schleuder,
      mode    => '0640';
    '/etc/schleuder/schleuder.conf':
      source  => ["puppet:///modules/site_schleuder/config/${::fqdn}/schleuder.conf",
                  'puppet:///modules/site_schleuder/config/schleuder.conf',
                  'puppet:///modules/schleuder/config/schleuder.conf' ],
      owner   => root,
      group   => schleuder,
      mode    => '0640';
    '/var/log/schleuder':
      ensure  => directory,
      require => User::Managed['schleuder'],
      # as we might run schleuder as different user,
      # the log file schould be writeable for the group.
      owner   => schleuder,
      group   => schleuder,
      mode    => '0660';
  }
}
