# frozen_string_literal: true
module NetTester
  # Directories used by NetTester
  module Dir
    def log_dir
      maybe_create './log'
    end

    def socket_dir
      maybe_create './tmp/sockets'
    end

    def pid_dir
      maybe_create './tmp/pids'
    end

    private

    def maybe_create(dir)
      dir.tap { |path| FileUtils.mkdir_p(path) unless File.exist?(path) }
    end
  end
end
