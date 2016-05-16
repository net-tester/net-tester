# frozen_string_literal: true
require 'active_support/core_ext/array/access'
require 'net_tester/link'

module NetTester
  describe Link do
    def delete_all_link
      `ifconfig -a`.split("\n").select { |each| /^link\d+-1/=~ each }.each do |each|
        /^(link\d+-1)/=~ each
        system "sudo ip link delete #{Regexp.last_match(1)}"
      end
    end

    after(:all) { delete_all_link }

    context 'with no link' do
      Given { delete_all_link }

      describe '.all' do
        When(:all) { Link.all }
        Then { all == [] }
      end

      describe '.create' do
        When(:link) { Link.create }
        When(:all) { Link.all }
        Then { all.size == 1 }
        Then { all.first.devices.map(&:to_s) == ['link0-1', 'link0-2'] }

        describe '#destroy' do
          When { link.destroy }
          Then { Link.all == [] }
        end
      end

      describe '.destroy_all' do
        When { Link.destroy_all }
        When(:all) { Link.all }
        Then { all == [] }
      end
    end
  end
end
