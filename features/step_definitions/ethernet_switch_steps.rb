# frozen_string_literal: true

Given(/^テスト対象のイーサネットスイッチ$/) do
  @testee_switch = TesteeSwitch.create(dpid: 0x1, tcp_port: 6654)
  step %(I successfully run `trema run ../../vendor/learning_switch/lib/learning_switch.rb --port 6654 -L #{Phut.log_dir} -P #{Phut.pid_dir} -S #{Phut.socket_dir} --daemon`)
end
