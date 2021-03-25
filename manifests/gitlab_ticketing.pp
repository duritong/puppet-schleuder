# manage schleuder-gitlab-ticketing config
class schleuder::gitlab_ticketing (
  Array[String] $subject_filters = [],
  Array[String] $sender_filters = [],
  Optional[
    Struct[{ endpoint => String, token => String }]
  ]           $gitlab = undef,
  Hash[String,
    Struct[{
        Optional[gitlab]          => Struct[{
            Optional[endpoint]      => String,
        Optional[token]         => String, }],
        project                   => String,
        namespace                 => String,
        Optional[ticket_prefix]   => String,
        Optional[subject_filters] => Array[String],
        Optional[sender_filters]  => Array[String],
  }]]         $lists = {},
) {
  file { '/etc/schleuder/gitlab.yml': }
  if !empty($lists) {
    File['/etc/schleuder/gitlab.yml'] {
      content => template('schleuder/gitlab_ticketing/config.yml.erb'),
      owner   => root,
      group   => 'schleuder',
      mode    => '0640',
      require => Package['schleuder'],
      before  => Service['schleuder-api-daemon'],
    }
  } else {
    File['/etc/schleuder/gitlab.yml'] {
      ensure => absent,
    }
  }
}
