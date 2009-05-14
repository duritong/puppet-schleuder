class schleuder::base {
  include rubygems::tmail
  include rubygems::gpgme
  
  if $schleuder_enable_highline {
    include rubygems::highline
  }

  if $schleuder_install_dir == '' {
    $schleuder_install_dir  = '/opt/schleuder'
  }

  group{'schleuder':
    ensure => present,
  }

  git::clone{'schleuder':
    git_repo => 'git://git.immerda.ch/schleuder.git',
    projectroot => $schleuder_install_dir,
    cloneddir_group => 'schleuder',
    require => [ Group['schleuder'], Package['tmail'], Package['ruby-gpgme'] ],
  }

  file{ [ '/etc/schleuder', '/var/schleuderlists' ]:
    ensure => directory,
    require => Group['schleuder'],
    owner => root, group => schleuder, mode => 0640;
  }

  file{'/etc/schleuder/default-list.conf':
    source => [ "puppet://$server/files/schleuder/config/${fqdn}/default-list.conf",
                "puppet://$server/files/schleuder/config/default-list.conf",
                "puppet://$server/schleuder/config/default-list.conf" ],
    owner => root, group => schleuder, mode => 0640;
  }
  file{'/etc/schleuder/schleuder.conf':
    source => [ "puppet://$server/files/schleuder/config/${fqdn}/schleuder.conf",
                "puppet://$server/files/schleuder/config/schleuder.conf",
                "puppet://$server/schleuder/config/schleuder.conf" ],
    owner => root, group => schleuder, mode => 0640;
  }

  file{'/var/log/schleuder.log':
    ensure => file,
    replace => false,
    require => Group['schleuder'],
    owner => root, group => schleuder, mode => 0660;
  }
}
