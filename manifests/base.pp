class schleuder::base {
  include rubygems::tmail
  include rubygems::gpgme
  
  if $schleuder_enable_highline {
    include rubygems::highline
  }

  if $schleuder_install_dir == '' {
    $schleuder_install_dir  = '/opt/schleuder'
  }

  user::managed{'schleuder':
    name_comment => 'schleuder user',
    managehome => false,
    homedir => '/var/schleuderlists',
    shell => $operatingsystem ? {
      debian => '/usr/sbin/nologin',
      ubuntu => '/usr/sbin/nologin',
      default => '/sbin/nologin'
    },
  }

  git::clone{'schleuder':
    git_repo => 'git://git.immerda.ch/schleuder.git',
    projectroot => $schleuder_install_dir,
    cloneddir_group => 'schleuder',
    require => [ User::Managed['schleuder'], Package['tmail'], Package['ruby-gpgme'] ],
  }

  file{["${schleuder_install_dir}/bin/schleuder", "${schleuder_install_dir}/contrib/newlist.rb" ]:
    require => Git::Clone['schleuder'],
    owner => root, group => 'schleuder', mode => 0750;
  }

  file{ [ '/etc/schleuder', '/var/schleuderlists', '/var/schleuderlists/initmemberkeys' ]:
    ensure => directory,
    require => [ User::Managed['schleuder'], Git::Clone['schleuder'] ],
    owner => root, group => schleuder, mode => 0640;
  }

  file{'/etc/schleuder/default-list.conf':
    source => [ "puppet://$server/files/schleuder/config/${fqdn}/default-list.conf",
                "puppet://$server/files/schleuder/config/default-list.conf",
                "puppet://$server/modules/schleuder/config/default-list.conf" ],
    owner => root, group => schleuder, mode => 0640;
  }
  file{'/etc/schleuder/schleuder.conf':
    source => [ "puppet://$server/files/schleuder/config/${fqdn}/schleuder.conf",
                "puppet://$server/files/schleuder/config/schleuder.conf",
                "puppet://$server/modules/schleuder/config/schleuder.conf" ],
    owner => root, group => schleuder, mode => 0640;
  }

  file{'/var/log/schleuder':
    ensure => directory,
    recurse => true,
    require => User::Managed['schleuder'],
    # as we might run schleuder as different user,
    # the log file schould be writeable for the group.
    owner => schleuder, group => schleuder, mode => 0660;
  }
}
