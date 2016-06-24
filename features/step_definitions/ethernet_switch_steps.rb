# coding: utf-8
# frozen_string_literal: true
Given(/^イーサネットスイッチ \(DPID = "([^"]*)", tcp_port = (\d+)\)$/) do |dpid, tcp_port|
  @testee = TesteeSwitch.create(dpid: dpid.hex, tcp_port: tcp_port.to_i)
  cd('.') do
    step %(I successfully run `bundle exec trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
  end
end
