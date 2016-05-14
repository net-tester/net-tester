# frozen_string_literal: true
require 'active_support/core_ext/array/access'
require 'net_tester/switch'

module NetTester
  describe Switch do
    def delete_all_bridge
      `sudo ovs-vsctl list-br`.chomp.split.each do |each|
        next unless /^nts/=~ each
        system "sudo ovs-vsctl del-br #{each}"
      end
    end

    after(:all) { delete_all_bridge }

    context 'with no switch' do
      Given { delete_all_bridge }

      describe '.all' do
        When(:all) { Switch.all }
        Then { all == [] }
      end

      describe '.create' do
        context 'with dpid: 0xc001' do
          When(:switch) { Switch.create dpid: 0xc001 }
          When(:all) { Switch.all }
          Then { all.size == 1 }
          Then { all.first.dpid == 0xc001 }
          Then { all.first.running? == true }

          describe '#add_port' do
            context "with 'port1'" do
              When { switch.add_port 'port1' }
              Then { switch.ports == ['port1'] }
            end
          end

          describe '#stop' do
            When { switch.stop }
            Then { Switch.all.empty? }
          end
        end
      end

      describe '.destroy_all' do
        When { Switch.destroy_all }
        When(:all) { Switch.all }
        Then { all == [] }
      end
    end

    context 'with a switch (DPID = 0xdeadbeef)' do
      Given { delete_all_bridge }
      Given { system 'sudo ovs-vsctl add-br nts0xdeadbeef' }

      describe '.all' do
        When(:all) { Switch.all }

        Then { all.size == 1 }
        Then { all.first.dpid == 0xdeadbeef }
      end

      describe '.create' do
        context 'with 0xcafebabe' do
          When { Switch.create dpid: 0xcafebabe }
          When(:all) { Switch.all }

          Then { all.size == 2 }
          Then { all.sort.first.dpid == 0xcafebabe }
          Then { all.sort.second.dpid == 0xdeadbeef }
        end

        context 'with 0xdeadbeef' do
          When(:result) { Switch.create dpid: 0xdeadbeef }
          Then { result == Failure(RuntimeError, /cannot create a bridge named nts0xdeadbeef/) }
        end
      end

      describe '.destroy_all' do
        When { Switch.destroy_all }
        When(:all) { Switch.all }
        Then { all == [] }
      end
    end
  end
end
