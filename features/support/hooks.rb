# frozen_string_literal: true
Before do
  Dir.chdir 'tmp/aruba' do
    FileUtils.mkdir_p('./log') unless File.exist?('./log')
    FileUtils.mkdir_p('./pids') unless File.exist?('./pids')
    FileUtils.mkdir_p('./sockets') unless File.exist?('./sockets')

    Phut.log_dir = './log'
    Phut.pid_dir = './pids'
    Phut.socket_dir = './sockets'
  end
end

After do
  Dir.chdir 'tmp/aruba' do
    Phut.log_dir = './log'
    Phut.pid_dir = './pids'
    Phut.socket_dir = './sockets'

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
