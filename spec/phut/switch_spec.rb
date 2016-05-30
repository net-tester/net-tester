# frozen_string_literal: true
require 'active_support/core_ext/array/access'
require 'phut/switch'

module Phut
  describe Switch do
    def delete_all_bridge
      `sudo ovs-vsctl list-br`.chomp.split.each do |each|
        next unless /^#{Switch.prefix}/ =~ each
        system "sudo ovs-vsctl del-br #{each}"
      end
    end

    after(:each) { delete_all_bridge }

    describe '.all' do
      When(:all) { Switch.all }

      context 'when there is no switch' do
        Then { all == [] }
      end

      context 'when there is a switch (dpid = 0xc001)' do
        Given { Switch.create dpid: 0xc001 }
        Then { all.size == 1 }
        Then { all.first.dpid == 0xc001 }
      end
    end

    describe '.create' do
      context 'with dpid: 0xc001' do
        When(:switch) { Switch.create dpid: 0xc001 }

        context 'when there is no switch' do
          Then { switch.dpid == 0xc001 }
          Then { switch.name == '0xc001' }
          Then { switch.running? == true }
        end

        context 'when there is a switch (dpid = 0xc001)' do
          Given { Switch.create dpid: 0xc001 }
          Then { switch == Failure(RuntimeError, /cannot create a bridge named 0xc001/) }
        end
      end

      context "with name: 'dadi', dpid: 0xc001" do
        When(:switch) { Switch.create name: 'dadi', dpid: 0xc001 }

        context 'when there is no switch' do
          Then { switch.name == 'dadi' }
          Then { switch.dpid == 0xc001 }
          Then { switch.running? == true }
        end
      end
    end

    describe '.destroy_all' do
      When { Switch.destroy_all }
      Then { Switch.all == [] }
    end

    describe '#add_port' do
      Given(:switch) { Switch.create dpid: 0xc001 }

      context "with 'port1'" do
        When { switch.add_port 'port1' }
        Then { switch.ports == ['port1'] }
      end
    end

    describe '#stop' do
      Given(:switch) { Switch.create dpid: 0xc001 }
      When { switch.stop }
      Then { switch.running? == false }
    end
  end
end
