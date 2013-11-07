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
#
# schleuder_enable_highline:
#   wether we'd like to install highline support for
#   schleuder or not.
# schleuder_install_dir:
#   The directory in which you'd like to install schleuder
#   Default: '/opt/schleuder',
class schleuder(
  $enable_highline = true,
  $install_dir     = '/opt/schleuder',
) {
  include schleuder::base
}
