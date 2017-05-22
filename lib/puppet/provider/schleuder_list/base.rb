require 'puppet/provider/parsedfile'

Puppet::Type.type(:schleuder_list).provide(:base) do
  has_command(:cli, '/usr/bin/schleuder-cli') do
    environment({ 'HOME' => ENV['HOME'] })
  end

  mk_resource_methods

  # Return a list of existing schleuder lists
  def self.instances
    cli('lists','list').
      split("\n").
      collect { |line| new(:ensure => :present, :name => line.strip) }
  end

  # Prefetch our list list, yo.
  def self.prefetch(lists)
    instances.each do |prov|
      if list = lists[prov.name] || lists[prov.name.downcase]
        list.provider = prov
      end
    end
  end

  # Create the list.
  def create
    args = ['lists','new']

    args << self.name
    if val = @resource[:admin]
      args << val
    else
      raise ArgumentError, "Schleuder lists require an administrator email address"
    end
    if val = @resource[:admin_publickey]
      args << val
    else
      raise ArgumentError, "Schleuder lists require a public key of the admin"
    end
    cli(*args)
  end

  # Delete the list.
  def destroy
    args = ['lists','delete']
    args << self.name
    args << '--YES'
    cli(*args)
  end

  # Does our list exist already?
  def exists?
    properties[:ensure] != :absent
  end

  # Clear out the cached values.
  def flush
    @property_hash.clear
  end

  # Look up the current status.
  def properties
    if @property_hash.empty?
      @property_hash = query || {:ensure => :absent}
      @property_hash[:ensure] = :absent if @property_hash.empty?
    end
    @property_hash.dup
  end

  # Pull the current state of the list from the full list.  We're
  # getting some double entendre here....
  def query
    self.class.instances.each do |list|
      if list.name == self.name or list.name.downcase == self.name
        return list.properties
      end
    end
    nil
  end
end

