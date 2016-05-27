# frozen_string_literal: true
require 'active_support/core_ext/array/access'
require 'phut/link'

module Phut
  describe Link do
    def delete_all_link
      `ifconfig -a`.split("\n").each do |each|
        next unless /^(lnk\S+)/=~ each
        system "sudo ip link delete #{Regexp.last_match(1)} 2>/dev/null"
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
        When(:link) { Link.create(:name1, :name2) }
        When(:all) { Link.all }
        Then { all.size == 1 }

        describe '#device' do
          Then { link.device(:name1) == 'lnk0_name1' }
          Then { link.device(:name2) == 'lnk0_name2' }
        end

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
