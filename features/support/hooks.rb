# frozen_string_literal: true
After do
  cd('.') do
    NetTester::Command.kill
    # FIXME: Trema.kill_all
    begin
      Trema.trema_process('LearningSwitch', socket_dir).killall
    rescue
      true
    end
    begin
      Trema.trema_process('PacketInLogger', socket_dir).killall
    rescue
      true
    end
  end
end
