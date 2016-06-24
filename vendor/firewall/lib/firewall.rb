class Firewall < Trema::Controller
  # A database that keeps pairs of a MAC address and a port number
  class FDB
    # Forwarding database (FDB) entry.
    class Entry
      DEFAULT_AGE_MAX = 300

      attr_reader :mac
      attr_reader :port_no

      def initialize(mac, port_no, age_max = DEFAULT_AGE_MAX)
        @mac = mac
        @port_no = port_no
        @age_max = age_max
        @last_update = Time.now
      end

      def update(port_no)
        @port_no = port_no
        @last_update = Time.now
      end

      def aged_out?
        Time.now - @last_update > @age_max
      end
    end

    def initialize
      @db = {}
    end

    def lookup(mac)
      entry = @db[mac]
      entry && entry.port_no
    end

    def learn(mac, port_no)
      entry = @db[mac]
      if entry
        entry.update port_no
      else
        @db[mac] = Entry.new(mac, port_no)
      end
    end

    def age
      @db.delete_if { |_mac, entry| entry.aged_out? }
    end
  end

  def start(_argv)
    @fdb = FDB.new
  end

  def packet_in(dpid, packet_in)
    begin
      return if packet_in.ether_type == 0x86dd
      return if packet_in.in_port == 1 && packet_in.data.transport_destination_port.to_i != 8080
      logger.info "packet_in: DPID=#{dpid.to_hex}, data=#{packet_in.data.inspect}"
    rescue
      logger.info $!.to_s
      return
    end
    @fdb.learn packet_in.source_mac, packet_in.in_port
    flow_mod_and_packet_out packet_in
  end

  private

  def flow_mod_and_packet_out(packet_in)
    port_no = @fdb.lookup(packet_in.destination_mac)
    flow_mod(packet_in, port_no) if port_no
    packet_out(packet_in, port_no || :flood)
  end

  def flow_mod(packet_in, port_no)
    send_flow_mod_add(
      packet_in.datapath_id,
      match: ExactMatch.new(packet_in),
      actions: SendOutPort.new(port_no)
    )
  end

  def packet_out(packet_in, port_no)
    send_packet_out(
      packet_in.datapath_id,
      packet_in: packet_in,
      actions: SendOutPort.new(port_no)
    )
  end
end
