# coding: utf-8
# frozen_string_literal: true

def debug_ovs(name)
  $stderr.puts "Switch #{name}"
  $stderr.puts `sudo ovs-ofctl dump-flows #{name} -O OpenFlow10`
  $stderr.puts `sudo ovs-ofctl show #{name}`
end

Given(/^NetTester とテストホスト (\d+) 台を起動$/) do |nhost|
  NetTester::Command.run nhost.to_i
end

Given(/^テスト対象のネットワークに PacketIn を調べる OpenFlow スイッチ$/) do
  Switch.create(dpid: 0x1, port: 6654)
  # TODO: cucumber/aruba でも project_root/log と project_root/tmp/{sockets,pids} を使うようにすればよい?
  # Aruba で PacketInLogger.log をテストするので、tmp/aruba に cd する
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../fixtures/packet_in_logger.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^テスト対象のネットワークにイーサネットスイッチが 1 台$/) do
  Switch.create(dpid: 0x1, port: 6654)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{log_dir} -P #{pid_dir} -S #{socket_dir} --daemon`)
  end
end

Given(/^DPID が (\S+) の NetTester 物理スイッチ$/) do |dpid|
  @physical_test_switch = PhysicalTestSwitch.create(dpid: dpid.hex)
end

Given(/^テスト対象のスイッチとテスト用物理スイッチをリンク (\d+) 本で接続$/) do |nhost|
  nhost.to_i.times do |each|
    tport_name = "tport#{each + 1}"
    port_name = "pport#{each + 1}"
    link = Link.create(tport_name, port_name)
    @physical_test_switch.add_port(link.device(port_name))
    # FIXME: Switch.find_by(name: testee_switch.name).add_port ...
    Switch.all.first.add_port link.device(tport_name)
  end
end

Given(/^NetTester 物理スイッチとテスト対象のスイッチを次のように接続:$/) do |table|
  table.hashes.each do |each|
    pport_id = each['Physical Port'].to_i
    tport_id = each['Testee Port'].to_i
    port_name = "pport#{pport_id}"
    tport_name = "tport#{tport_id}"
    link = Link.create(tport_name, port_name)
    @physical_test_switch.add_numbered_port(pport_id, link.device(port_name))
    # FIXME: Switch.find_by(name: testee_switch.name).add_port ...
    Switch.all.first.add_numbered_port tport_id, link.device(tport_name)
  end
end

Given(/^テストホストと NetTester 仮想スイッチを次のように接続:$/) do |table|
  table.hashes.each do |each|
    NetTester::Command.connect_host(host_id: each['Test Host'],
                                    port_number: each['Virtual Port'].to_i)
  end
end

Given(/^NetTester サーバとテスト用物理スイッチをリンクで接続$/) do
  @physical_test_switch.add_port(@main_link.device(:psw))
end

Given(/^NetTester 仮想スイッチと物理スイッチを次のように接続$/) do |table|
  # FIXME: リンクは一本だけなので each しない
  table.hashes.each do |each|
    main_link = Link.create('ssw', 'psw')
    NetTester::Command.connect_switch(device: main_link.device(:ssw), port_number: each['Virtual Port'].to_i)
    @physical_test_switch.add_numbered_port(each['Physical Port'].to_i, main_link.device(:psw))
  end
end

Given(/^NetTester と VLAN を有効にしたテストホスト (\d+) 台を起動:$/) do |nhost, table|
  splink = Link.create('ssw', 'psw')
  vlan_option = + table.hashes.map do |each|
    each['Host'] + ':' + each['VLAN ID']
  end.join(',')
  step "I successfully run `net_tester run --nhost #{nhost} --vlan #{vlan_option} --device #{splink.device(:ssw)}`"
  physical_test_switch = PhysicalTestSwitch.create(dpid: 0xdef)
  nhost.to_i.times do |each|
    tport_name = "tport#{each + 1}"
    port_name = "pport#{each + 1}"
    link = Link.create(tport_name, port_name)
    physical_test_switch.add_port(link.device(port_name))
    Switch.all.first.add_port link.device(tport_name)
  end
  physical_test_switch.add_port(splink.device(:psw))
end

When(/^次のパッチを追加:$/) do |table|
  table.hashes.each do |each|
    NetTester::Command.add(each['Virtual Port'].to_i, each['Physical Port'].to_i)
  end
end

When(/^各テストホストから次のようにパケットを送信:$/) do |table|
  table.hashes.each do |each|
    NetTester::Command.send_packet("host#{each['Source Host']}", "host#{each['Destination Host']}")
  end
  sleep 1
end

Then(/^各テストホストは次のようにパケットを受信する:$/) do |table|
  table.hashes.each do |each|
    packets_received = NetTester::Command.packets_received("host#{each['Destination Host']}", "host#{each['Source Host']}")
    expect(packets_received).to be 1
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn が届く:$/) do |table|
  table.hashes.each do |each|
    if each['VLAN ID']
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}, VLAN ID = #{each['VLAN ID']}")
    else
      step %(the file "#{File.join log_dir, 'PacketInLogger.log'}" should contain "PACKET_IN: Port = #{each['Port']}")
    end
  end
end

Then(/^テスト対象の OpenFlow スイッチの次のポートに PacketIn は届かない:$/) do |table|
  table.hashes.each do |each|
    cd('.') do
      expect(IO.readlines("#{log_dir}/PacketInLogger.log").any? { |line| /PACKET_IN #{each['port']}/ =~ line }).to be false
    end
  end
end
