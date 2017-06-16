Puppet::Type.newtype(:quagga_community_list) do
  @doc = %q{

    This type provides the capability to manage community-list
    within puppet.

      Examples:

        quagga_community_list { '100':
            ensure => present,
            rules  => [
                'permit 65000:50952',
                'permit 65000:31500',
            ],
        }
  }

  ensurable

  newparam(:name) do
    desc %q{ Community list number. }

    newvalues(/^\d+$/)

    validate do |value|
      value_i = value.to_i
      if value_i < 1 or value_i > 500
        raise ArgumentError, 'Community list number: 1-500'
      end
    end
  end

  newproperty(:rules, :array_matching => :all) do
    desc %q{ Action and community. }

    newvalues(/\A(deny|permit)\s\d+:\d+\Z/)

    def should_to_s(value = @should)
      if value
        value.inspect
      else
        nil
      end
    end
  end

  autorequire(:package) do
    case value(:provider)
      when :quagga
        %w{quagga}
      else
        []
    end
  end

  autorequire(:service) do
    case value(:provider)
      when :quagga
        %w{zebra bgpd}
      else
        []
    end
  end
end