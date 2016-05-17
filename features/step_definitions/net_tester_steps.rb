# coding: utf-8
# frozen_string_literal: true
Given(/^NetTester とテストホスト (\d+) 台を起動$/) do |nhost|
  splink = Link.create('ssw', 'psw')
  step "I successfully run `net_tester run --nhost #{nhost} --device #{splink.device(:ssw)}`"
  @physical_test_switch = PhysicalTestSwitch.create(dpid: 0xdef)
  nhost.to_i.times do |each|
    tport_name = "tport#{each + 1}"
    port_name = "pport#{each + 1}"
    link = Link.create(tport_name, port_name)
    @physical_test_switch.add_port(link.device(port_name))
    Switch.all.first.add_port link.device(tport_name)
  end
  @physical_test_switch.add_port(splink.device(:psw))
end

Given(/^NetTester と VLAN を有効にしたテストホスト (\d+) 台を起動:$/) do |nhost, table|
  splink = Link.create('ssw', 'psw')
  vlan_option = + table.hashes.map do |each|
    each['Host'] + ':' + each['VLAN ID']
  end.join(',')
  step "I successfully run `net_tester run --nhost #{nhost} --vlan #{vlan_option} --device #{splink.device(:ssw)}`"
  @physical_test_switch = PhysicalTestSwitch.create(dpid: 0xdef)
  nhost.to_i.times do |each|
    tport_name = "tport#{each + 1}"
    port_name = "pport#{each + 1}"
    link = Link.create(tport_name, port_name)
    @physical_test_switch.add_port(link.device(port_name))
    Switch.all.first.add_port link.device(tport_name)
  end
  @physical_test_switch.add_port(splink.device(:psw))
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
    # TODO: make message#vlan? work
    if Pio::Parser::EthernetFrame.read(message.raw_data).ether_type.to_i == Pio::EthernetHeader::EtherType::VLAN
       logger.info "PACKET_IN: Port = \#{message.in_port}, VLAN ID = \#{Pio::Parser.read(message.raw_data).vlan_vid_internal}"
     else
       logger.info "PACKET_IN: Port = \#{message.in_port}"
     end
  rescue
    logger.error $!.inspect
  end
end
EOF
  cd('.') do
    step %(I successfully run `bundle exec trema run packet_in_logger.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

When(/^次のパッチを追加:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester add --vport #{each['Virtual Port']} --port #{each['Physical Port']}`"
  end
end

When(/^各テストホストから次のようにパケットを送信:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester send_packet --source host#{each['Source Host']} --dest host#{each['Destination Host']}`"
  end
  sleep 1
end

Then(/^各テストホストは次のようにパケットを受信する:$/) do |table|
  table.hashes.each do |each|
    step "I successfully run `net_tester received_packets --dest host#{each['Destination Host']} --source host#{each['Source Host']}`"
    step %(the output from "net_tester received_packets --dest host#{each['Destination Host']} --source host#{each['Source Host']}" should contain exactly "1")
  end
end

Then(/^テスト対象の OpenFlow スイッチに次の PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    if each['VLAN ID']
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}, VLAN ID = #{each['VLAN ID']}")
    else
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}")
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチに次の PacketIn は届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines("#{log_dir}/PacketInLogger.log").any? { |line| /PACKET_IN #{each['port']}/ =~ line }).to be false
    end
  end
end
