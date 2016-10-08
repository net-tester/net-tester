# coding: utf-8
# frozen_string_literal: true

Given(/^テストホスト (\d+) 台を起動$/) do |nhost|
  main_link = Phut::Link.create('ssw', 'psw')
  NetTester.run(network_device: main_link.device(:ssw),
                physical_switch_dpid: @physical_test_switch.dpid)
  @physical_test_switch.add_numbered_port(1, main_link.device(:psw))
  NetTester.add_host nhost.to_i
  sleep 1
end

Then(/^各テストホストは以下の数パケットを受信する:$/) do |table|
  table.hashes.each do |each|
    packets_received = NetTester.packets_received("host#{each['Destination Host']}", "host#{each['Source Host']}")
    expect(packets_received).to be each['Received Packets'].to_i
  end
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
