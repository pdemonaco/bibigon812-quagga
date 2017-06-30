require 'spec_helper'

describe Puppet::Type.type(:quagga_bgp_address_family).provider(:quagga) do
  describe 'instance' do
    it 'should have an instances method' do
      expect(described_class).to respond_to :instances
    end

    it 'should have a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end

  context 'running-config without default ipv4-unicast' do
    before :each do
      described_class.expects(:vtysh).with(
          '-c', 'show running-config'
      ).returns '!
router bgp 197888
 bgp router-id 172.16.32.103
 no bgp default ipv4-unicast
 bgp graceful-restart stalepath-time 300
 bgp graceful-restart restart-time 300
 bgp network import-check
 network 172.16.32.0/24
 neighbor INTERNAL peer-group
 neighbor INTERNAL remote-as 197888
 neighbor INTERNAL allowas-in 1
 neighbor INTERNAL update-source 172.16.32.103
 neighbor INTERNAL activate
 neighbor INTERNAL next-hop-self
 neighbor INTERNAL soft-reconfiguration inbound
 neighbor RR peer-group
 neighbor RR remote-as 197888
 neighbor RR update-source 172.16.32.103
 neighbor RR activate
 neighbor RR next-hop-self
 neighbor RR_WEAK peer-group
 neighbor RR_WEAK remote-as 197888
 neighbor RR_WEAK update-source 172.16.32.103
 neighbor RR_WEAK activate
 neighbor RR_WEAK next-hop-self
 neighbor RR_WEAK route-map RR_WEAK_out out
 neighbor 172.16.32.108 peer-group INTERNAL
 neighbor 172.16.32.108 default-originate
 neighbor 172.16.32.108 shutdown
 neighbor 1a03:d000:20a0::91 remote-as 31113
 neighbor 1a03:d000:20a0::91 update-source 1a03:d000:20a0::92
 maximum-paths 4
 maximum-paths ibgp 4
!
 address-family ipv6
 network 1a04:6d40::/48
 neighbor 1a03:d000:20a0::91 activate
 neighbor 1a03:d000:20a0::91 allowas-in 1
 exit-address-family
!
end'
    end

    it 'should return a resource' do
      expect(described_class.instances.size).to eq(2)
    end

    it 'should return the \'197888 ipv4 unicast\' resource' do
      expect(described_class.instances[0].instance_variable_get('@property_hash')).to eq({
        ensure: :present,
        maximum_ebgp_paths: 4,
        maximum_ibgp_paths: 4,
        name: '197888 ipv4 unicast',
        networks: ['172.16.32.0/24',],
        provider: :quagga,
      })
    end

    it 'should return the \'197888 ipv6\' resource' do
      expect(described_class.instances[1].instance_variable_get('@property_hash')).to eq({
         ensure: :present,
         maximum_ebgp_paths: 1,
         maximum_ibgp_paths: 1,
         name: '197888 ipv6',
         networks: ['1a04:6d40::/48',],
         provider: :quagga,
      })
    end
  end
end