# coding: utf-8
# frozen_string_literal: true

# rubocop:disable MethodLength
def cleanup
  Command.kill
  PhysicalTestSwitch.destroy_all
  TesteeSwitch.destroy_all
  TesteeFirewall.destroy_all

  # FIXME: Trema.kill_all
  begin
    Trema.trema_process('LearningSwitch', Phut.socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
  begin
    Trema.trema_process('PacketInLogger', Phut.socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
  begin
    Trema.trema_process('Firewall', Phut.socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
end
# rubocop:enable MethodLength

# frozen_string_literal: true
Before do
  Dir.chdir 'tmp/aruba'

  FileUtils.mkdir_p('./log') unless File.exist?('./log')
  FileUtils.mkdir_p('./tmp/pids') unless File.exist?('./tmp/pids')
  FileUtils.mkdir_p('./tmp/sockets') unless File.exist?('./tmp/sockets')

  Phut.log_dir = './log'
  Phut.pid_dir = './tmp/pids'
  Phut.socket_dir = './tmp/sockets'

  cleanup
end

Before('@firewall_example') do
  steps %(
    Given ファイアウォールをシミュレートするスイッチ (DPID = "0x1", tcp_port = 6654)
    And NetTester を DPID = "0x123" で起動
    And NetTester 物理スイッチ (DPID = "0x123")
    And NetTester 物理スイッチとテスト対象のスイッチを次のように接続:
      | Physical Port | Testee Port |
      |             2 |           2 |
      |             3 |           3 |
  )
end

After do
  Phut.log_dir = './log'
  Phut.pid_dir = './tmp/pids'
  Phut.socket_dir = './tmp/sockets'

  pid = `sudo ip netns exec server lsof -i tcp:8080 -t`
  system "sudo ip netns exec server kill -9 #{pid}" unless pid.empty?
  pid = `sudo ip netns exec server lsof -i tcp:3000 -t`
  system "sudo ip netns exec server kill -9 #{pid}" unless pid.empty?

  cleanup

  Dir.chdir '../..'
end
