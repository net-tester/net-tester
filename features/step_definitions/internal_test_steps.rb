# coding: utf-8
# frozen_string_literal: true

Given(/^VLAN を有効にしたテストホスト (\d+) 台を起動:$/) do |nhost, table|
  vlan_option = + table.hashes.map do |each|
    "host#{each['Host']}:#{each['VLAN ID']}"
  end.join(',')
  NetTester.run @physical_test_switch_dpid, vlan_option
  NetTester.add_host nhost.to_i
  sleep 1
end

Then(/^OpenFlow コントローラが停止$/) do
  step 'the file "tmp/pids/NetTesterController.pid" should not exist'
end

Then(/^すべてのスイッチが停止$/) do
  expect(TesteeSwitch.all).to be_empty
end

Then(/^次の仮想ホストがすべて停止:$/) do |hosts|
  files = hosts.raw.flatten.map { |each| "tmp/pids/vhost.#{each}.pid" }
  expect(files).not_to include be_an_existing_file
end

Then(/^すべてのリンクが停止$/) do
  expect(Phut::Link.all).to be_empty
end
