# frozen_string_literal: true

module NetTester

  class Process
    @@mutex = Mutex.new
    @@process_id_counter = 0
    @@processes = {}

    def self.all
      @@processes
    end

    def self.find(id)
      @@processes[id]
    end

    def self.destroy_all
      @@mutex.synchronize do
        @@processes.clear
      end
    end

    def initialize(host_name:, initial_wait: 3, process_wait: 1)
      @@mutex.synchronize do
        @id = @@process_id_counter = @@process_id_counter + 1
        @host_name = host_name
        @log_dir = File.join(Aruba.config.working_directory, 'processes', @id.to_s)
        FileUtils.mkdir_p(@log_dir) unless File.exist?(@log_dir)
        @stdout_file = File.join(@log_dir, 'stdout.log')
        @stderr_file = File.join(@log_dir, 'stderr.log')
        @initial_wait = initial_wait
        @process_wait = process_wait
        @stdout = ''
        @stderr = ''
        @status = 'created'
        @@processes[@id] = self
      end
    end

    def id
      @id
    end

    def stdout
      @stdout
    end

    def stderr
      @stderr
    end

    def status
      @status
    end

    def exec(command)
      thread = Thread.start do
        begin
          @status = 'waiting initial wait'
          sleep @initial_wait
          @status = 'running'
          host = Phut::Netns.find_by(name: @host_name)
          raise "no such host: #{@host_name}" if host.nil?
          host.exec "#{command} 1> #{@stdout_file} 2> #{@stderr_file}"
          @status = 'waiting process wait'
          sleep @process_wait
          @stdout = File.read(@stdout_file)
          @stderr = File.read(@stderr_file)
        rescue => e
          @stderr = e
        end
        @status = 'finished'
      end
    end
  end
end

