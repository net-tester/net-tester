# frozen_string_literal: true
Before do
  Dir.chdir 'tmp/aruba' do
    NetTester.log_dir = './log'
    NetTester.pid_dir = './pids'
    NetTester.socket_dir = './sockets'
    NetTester.process_dir = './processes'
    NetTester.testlet_dir = './testlets'
  end
end

After do
  Dir.chdir 'tmp/aruba' do
    NetTester.log_dir = './log'
    NetTester.pid_dir = './pids'
    NetTester.socket_dir = './sockets'
    NetTester.process_dir = './processes'
    NetTester.testlet_dir = './testlets'

    NetTester.kill
    PhysicalTestSwitch.destroy_all
    TesteeSwitch.destroy_all

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
  end
end
