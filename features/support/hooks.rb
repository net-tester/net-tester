# frozen_string_literal: true
Before do
  Dir.chdir 'tmp/aruba'

  FileUtils.mkdir_p('./log') unless File.exist?('./log')
  FileUtils.mkdir_p('./tmp/pids') unless File.exist?('./tmp/pids')
  FileUtils.mkdir_p('./tmp/sockets') unless File.exist?('./tmp/sockets')

  Phut.log_dir = './log'
  Phut.pid_dir = './tmp/pids'
  Phut.socket_dir = './tmp/sockets'
end

After do
  Phut.log_dir = './log'
  Phut.pid_dir = './tmp/pids'
  Phut.socket_dir = './tmp/sockets'

  Command.kill
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

  Dir.chdir '../..'
end
