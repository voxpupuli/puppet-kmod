Puppet::Type.newtype(:kmod_setting) do
  @doc = "Manages kernel module settings"

  ensurable do
    defaultvalues
  end

  newparam(:name, :namevar => true) do
    desc "The kmod setting module name."
  end

  newparam(:category) do
    desc "The setting category."

    newvalues :alias, :blacklist, :install, :options
  end

  newparam(:option) do
    desc "Optional setting option key."
  end

  newproperty(:value) do
    desc "Optional setting option value."
  end

  newparam(:target) do
    desc "The file in which to store the variable."
  end

  autorequire(:file) do
    self[:target]
  end
end

