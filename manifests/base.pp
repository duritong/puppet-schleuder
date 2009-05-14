class schleuder::base {
  include rubygems::tmail
  include rubygems::gpgme
  
  if $schleuder_enable_highline {
    include rubygems::highline
  }

  if $schleuder_install_dir == '' {
    $schleuder_install_dir  = '/opt/schleuder'
  }

  git::clone{'schleuder':
    git_repo => 'git://git.immerda.ch/schleuder.git',
    projectroot => $schleuder_install_dir,
    cloneddir_restrict_mode => false,
    require => [ Package['tmail'], Package['ruby-gpgme'] ],
  }
}
