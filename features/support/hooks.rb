# frozen_string_literal: true
Before do
  FileUtils.mkdir_p 'tmp/pids'
end

After do
  Switch.destroy_all
  TestSwitch.destroy
  PhysicalTestSwitch.destroy
  Host.destroy_all
  Link.destroy_all
  system 'bundle exec trema killall NetTester 2>/dev/null'
  system 'bundle exec trema killall LearningSwitch 2>/dev/null'
end
