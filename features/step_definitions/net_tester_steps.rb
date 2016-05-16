# coding: utf-8
# frozen_string_literal: true
Given(/^NetTester とテストホスト (\d+) 台を起動$/) do |nhost|
  step 'NetTester マシン用ネットワークデバイスの代わりに仮想リンクを作る'
  step "テストホスト #{nhost} 台を起動"
  step "テスト用の物理スイッチの代わりに Open vSwitch を起動し、テスト対象のスイッチと #{nhost} 本のケーブルでつなぐ"
end

Given(/^NetTester マシン用ネットワークデバイスの代わりに仮想リンクを作る$/) do
  @link = Link.create
end

Given(/^テスト対象のネットワークにイーサネットスイッチが 1 台$/) do
  Switch.create(dpid: 0x1, port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチを起動$/) do
  Switch.create(dpid: 0x1, port: 6654)
  step 'a file named "packet_in_logger.rb" with:', <<-EOF
class PacketInLogger < Trema::Controller
  def packet_in(dpid, message)
    logger.info 'PACKET_IN ' + message.in_port.to_s
  end
end
EOF
  cd('.') do
    step %(I successfully run `bundle exec trema run packet_in_logger.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^テスト用の物理スイッチの代わりに Open vSwitch を起動し、テスト対象のスイッチと (\d+) 本のケーブルでつなぐ$/) do |nlink|
  @physical_test_switch = PhysicalTestSwitch.create(dpid: 0xdef)
  nlink.to_i.times do
    link = Link.create
    @physical_test_switch.add_port(link.devices.first)
    Switch.all.first.add_port link.devices.second
  end
  @physical_test_switch.add_port(@link.devices.second)
end

Given(/^テストホスト (\d+) 台を起動$/) do |nhost|
  step "I successfully run `net_tester run --nhost #{nhost} --device #{@link.devices.first}`"
end

When(/^次のパッチを追加:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester add --vport #{each['virtual port']} --port #{each['physical port']}`"
  end
end

When(/^各テストホストから次のようにパケットを送信:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester send_packet --source host#{each['source host']} --dest host#{each['destination host']}`"
  end
  sleep 1
end

Then(/^各テストホストは次のようにパケットを受信する:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester received_packets --dest host#{each['destination host']} --source host#{each['source host']}`"
    step %(the output from "net_tester received_packets --dest host#{each['destination host']} --source host#{each['source host']}" should contain exactly "1")
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines("#{log_dir}/PacketInLogger.log").any? { |line| /PACKET_IN #{each['port']}/ =~ line }).to be true
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートには PacketIn が届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines("#{log_dir}/PacketInLogger.log").any? { |line| /PACKET_IN #{each['port']}/ =~ line }).to be false
    end
  end
end
