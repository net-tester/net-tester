# frozen_string_literal: true
require 'open3'

module Phut
  # Utility methods for running external commands
  module Sh
    def sudo(command)
      sh "sudo #{command}"
    end

    def sh(command)
      stdout, stderr, status = Open3.capture3(command)
      raise %(Command '#{command}' failed: #{stderr}) unless status.success?
      stdout
    end
  end
end
