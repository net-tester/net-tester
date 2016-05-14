# frozen_string_literal: true
Before do
  cd('.') do
    FileUtils.mkdir_p log_dir
    FileUtils.mkdir_p pid_dir
    FileUtils.mkdir_p socket_dir
  end
end

After do
  Switch.destroy_all
  TestSwitch.destroy_all
  PhysicalTestSwitch.destroy_all
  Host.destroy_all(socket_dir: File.join('./tmp/aruba/', socket_dir))
  Link.destroy_all
  system "bundle exec trema killall NetTester -S #{File.join './tmp/aruba/', socket_dir} 2>/dev/null"
  system "bundle exec trema killall LearningSwitch -S #{File.join './tmp/aruba/', socket_dir} 2>/dev/null"
  system "bundle exec trema killall PacketInLogger -S #{File.join './tmp/aruba/', socket_dir} 2>/dev/null"
end
