module Puppet
  newtype(:schleuder_list) do
    @doc = "Manage schleuder lists.  This resource type can only create
      and remove lists; it cannot currently reconfigure them."

    ensurable do
      defaultvalues
    end

    newparam(:name, :namevar => true) do
      desc "The name of the schleuder list."
    end

    newparam(:admin) do
      desc "The email address of the administrator."
    end

    newparam(:admin_publickey) do
      desc "Path to the public key of the administrator"
    end

    autorequire(:package) do
      ['schleuder-cli']
    end
    autorequire(:file) do
      self[:admin_publickey] if self[:admin_publickey]
    end

  end
end
