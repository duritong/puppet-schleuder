#
# schleuder module
#
# Copyright 2009, admin(at)immerda.ch
#
# This program is free software; you can redistribute
# it and/or modify it under the terms of the GNU
# General Public License version 3 as published by
# the Free Software Foundation.
#

# The following variables are possible to tune this module:
class schleuder(
  $valid_api_keys  = [],
  $cli_api_key     = undef,
  $tls_fingerprint = getvar('::schleuder_tls_fingerprint'),
  $api_host        = 'localhost',
  $api_port        = '4443',
  $use_shorewall   = false,
  $database_config = {},
  $superadmin      = 'root@localhost',
  $adminkeys_path  = 'modules/site_schleuder/adminkeys',
  $lists           = {},
) {
  case $operatingsystem {
    'CentOS': { include schleuder::centos }
    default: { include schleuder::base }
  }
  if $use_shorewall and $api_host != 'localhost' {
    include schleuder::shorewall
  }

  create_resources('schleuder::list',$lists)
}
