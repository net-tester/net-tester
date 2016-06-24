# coding: utf-8
# frozen_string_literal: true
Given(/^ファイアウォールをシミュレートするスイッチ \(DPID = "([^"]*)", tcp_port = (\d+)\)$/) do |dpid, tcp_port|
  @testee = TesteeFirewall.create(dpid: dpid, tcp_port: tcp_port)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/firewall/lib/firewall.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
  end
end

Given(/^NetTester で次のホストを起動:$/) do |table|
  @mac_address = {}
  @netns ||= {}
  table.hashes.each do |each|
    @netns[each.fetch('Hostname')] =
      NetTester::Command.add_netns(name: each.fetch('Hostname'),
                                   ip_address: each.fetch('IP Address'))
    port_name = "port_#{each['Hostname']}"
    link = Phut::Link.create(each['Hostname'], port_name)
    NetTester::Command.connect_switch(device: link.device(port_name),
                                      port_number: each['Virtual Port'].to_i)
    @netns.fetch(each['Hostname']).device = link.device(each['Hostname'])
    @mac_address[each['Virtual Port'].to_i] = @netns.fetch(each['Hostname']).mac_address
  end

  # FIXME
  system "sudo ip netns exec client arp -s 192.168.0.100 #{@netns['server'].mac_address}"
  system "sudo ip netns exec server arp -s 192.168.0.1 #{@netns['client'].mac_address}"
end

Given(/^NetTester で HTTP クライアント用ホスト "([^"]*)" を IP アドレス "([^"]*)" で起動$/) do |name, ip_address|
  @netns ||= {}
  @netns[name] = NetTester::Command.add_netns(name: name, ip_address: ip_address)
end

Given(/^NetTester で HTTP サーバ用ホスト "([^"]*)" を IP アドレス "([^"]*)" で起動$/) do |name, ip_address|
  @netns ||= {}
  @netns[name] = NetTester::Command.add_netns(name: name, ip_address: ip_address)
end

Given(/^NetTester のホスト "([^"]*)" で Web サーバをポート (\d+) 番で起動$/) do |netns, port_number|
  system %(sudo ip netns exec #{netns} ruby -rwebrick -e 'WEBrick::HTTPServer.new(DocumentRoot: "./", Port: #{port_number}, ServerType: WEBrick::Daemon).start' 2>/dev/null)
end

When(/^NetTester のホスト "([^"]*)" から (\S+) を HTTP GET$/) do |netns, url|
  @response = `sudo ip netns exec #{netns} ruby -rnet/http -e "print Net::HTTP.get_response(URI.parse('#{url}')).code" 2>&1`
end

Then(/^HTTP ステータス (\d+) が返る$/) do |status_code|
  expect(@response).to eq(status_code)
end

Then(/^HTTP GET がタイムアウトで失敗する$/) do
  expect(@response).to include('Timeout')
end
