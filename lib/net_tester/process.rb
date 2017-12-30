# frozen_string_literal: true

module NetTester
  # Process class
  class Process
    @mutex = Mutex.new
    @process_id_counter = 0
    @processes = {}

    class << self
      attr_accessor :mutex, :process_id_counter, :processes
    end

    def self.all
      @processes
    end

    def self.find(id)
      @processes[id]
    end

    def self.destroy_all
      @mutex.synchronize do
        @processes.clear
      end
    end

    def self.create(process_params)
      host_name = process_params[:host_name]
      return nil, { error: "no such host: #{host_name}" } unless Phut::Netns.find_by(name: host_name)
      args = process_params.to_h.symbolize_keys
      args[:initial_wait] = args[:initial_wait].to_i unless args[:initial_wait].nil?
      args[:process_wait] = args[:process_wait].to_i unless args[:process_wait].nil?
      command = args.delete(:command)
      process = NetTester::Process.new(args)
      process.exec(command)
      [process, nil]
    end

    def initialize(host_name:, initial_wait: 3, process_wait: 1)
      self.class.mutex.synchronize do
        @id = self.class.process_id_counter = (self.class.process_id_counter + 1)
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
        self.class.processes[@id] = self
      end
    end

    attr_reader :id

    attr_reader :stdout

    attr_reader :stderr

    attr_reader :status

    def exec(command)
      Thread.start do
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
        rescue StandardError => e
          @stderr = e
        end
        @status = 'finished'
      end
    end
  end
end
