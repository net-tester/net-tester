# frozen_string_literal: true
After do
  NetTester::Command.kill

  # FIXME: Trema.kill_all
  begin
    Trema.trema_process('LearningSwitch', socket_dir).killall
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
  begin
    Dir.chdir 'tmp/aruba' do
      Trema.trema_process('PacketInLogger', socket_dir).killall
    end
  rescue DRb::DRbConnError
    true
  rescue
    true
  end
end
