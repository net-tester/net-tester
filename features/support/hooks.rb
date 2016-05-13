# frozen_string_literal: true
Before do
  FileUtils.mkdir_p 'tmp/pids'
  FileUtils.mkdir_p 'tmp/sockets'
end

After do
  Switch.destroy_all
  TestSwitch.destroy
  PhysicalTestSwitch.destroy
  Host.destroy_all
  Link.destroy_all
  system 'bundle exec trema killall NetTester -S ./tmp/sockets'
  system 'bundle exec trema killall LearningSwitch -S tmp/sockets 2>/dev/null'
  system 'bundle exec trema killall PacketInLogger -S tmp/sockets 2>/dev/null'
end
