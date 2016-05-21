# frozen_string_literal: true
After do
  cd('.') do
    NetTester::Command.kill
    begin
      # FIXME: Trema.trema_process('LearningSwitch').try(:killall)
      Trema.trema_process('LearningSwitch', socket_dir).killall
    rescue
      true
    end
    begin
      # FIXME: Trema.trema_process('PacketInLogger').try(:killall)
      Trema.trema_process('PacketInLogger', socket_dir).killall
    rescue
      true
    end
  end
end
