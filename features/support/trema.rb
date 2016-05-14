# frozen_string_literal: true
require 'trema'

def pid_dir
  path = './tmp/pids'
  FileUtils.mkdir_p(path) unless File.exist?(path)
  path
end

def socket_dir
  path = './tmp/sockets'
  FileUtils.mkdir_p(path) unless File.exist?(path)
  path
end

def log_dir
  path = './log'
  FileUtils.mkdir_p(path) unless File.exist?(path)
  path
end
