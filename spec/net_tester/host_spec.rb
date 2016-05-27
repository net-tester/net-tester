# coding: utf-8
# frozen_string_literal: true
require 'faker'
require 'net_tester/host'
require 'net_tester/link'

module NetTester
  describe Host do
    include Dir

    def destroy_all_host
      ::Dir.glob(File.join(socket_dir, 'vhost.*.ctl')).each do |each|
        DRbObject.new_with_uri("drbunix:#{each}").stop
      end
    end

    after(:each) do
      destroy_all_host
      Link.destroy_all
    end

    describe '.all' do
      Then { Host.all == [] }
    end

    describe '.create' do
      When(:host) do
        Host.create(name: 'myhost',
                    ip_address: Faker::Internet.ip_v4_address,
                    mac_address: Faker::Internet.mac_address,
                    device: device)
      end

      context 'with an invalid device' do
        Given(:device) { 'INVALID_DEVICE' }
        Then { pending '変なデバイスの場合 vhost run が exit status !=0 で死ぬようにする' }
      end

      context 'with a link device' do
        Given(:device) { Link.create('a', 'b').device('a') }
        Then { Host.all.size == 1 }
        Then { host.name == 'myhost' }
        Then { host.device == device }

        describe '#stop' do
          When { host.stop }
          Then { Host.all.empty? }
        end
      end
    end
  end
end
