# a small wrapper to manage init member keys and a schleuder_list
define schleuder::list(
  $ensure          = present,
  $admin           = undef,
  $admin_publickey = undef,
){
  if ($ensure == 'present') and !$admin {
    fail("Must pass adminaddress to Schleuder::List[${name}]")
  }

  include ::schleuder

  schleuder_list{
    $name:
      ensure => $ensure,
  }
  if $ensure == present {
    if $admin_publickey =~ /^\// {
      $real_admin_publickey = $admin_publickey
    } else {
      $real_admin_publickey = "/var/lib/schleuder/adminkeys/${name}_${admin}.pub"
      file{$real_admin_publickey:
        owner => 'root',
        group => 'schleuder',
        mode  => '0640'
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
  }
}
