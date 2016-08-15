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

Given(/^PacketIn を調べる OpenFlow スイッチ$/) do
  @testee_switch = TesteeSwitch.create(dpid: 0x1, tcp_port: 6654)
  step %(I successfully run `bundle exec trema run ../../fixtures/packet_in_logger.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    if each['VLAN ID']
      step %(the file "./log/PacketInLogger.log" should contain "PACKET_IN: Port = #{each['Port']}, VLAN ID = #{each['VLAN ID']}")
    else
      step %(the file "./log/PacketInLogger.log" should contain "PACKET_IN: Port = #{each['Port']}")
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn は届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines('./log/PacketInLogger.log').any? do |line|
               /PACKET_IN #{each['port']}/ =~ line
             end).to be false
    end
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
