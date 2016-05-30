# frozen_string_literal: true
Before do
  Dir.chdir 'tmp/aruba'
end

After do
  Command.kill
  PhysicalTestSwitch.destroy_all
  TesteeSwitch.destroy_all

  # FIXME: Trema.kill_all
  begin
    Trema.trema_process('LearningSwitch', socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
  begin
    Trema.trema_process('PacketInLogger', socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end

  Dir.chdir '../..'
end
