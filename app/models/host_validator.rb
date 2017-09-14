require 'resolv'

class HostValidator

  MAC_ADDRESS_PATTERN = /\A^([0-9a-zA-F]{2}:){5}[0-9a-zA-F]{2}$\z/
  IP_ADDRESS_PATTERN = Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex)

  attr_accessor :mac_address, :ip_address, :netmask, :gateway, :virtual_port_number, :physical_port_number, :vlan_id

  include ActiveModel::Model

  validates :mac_address, presence: true, format: { with: MAC_ADDRESS_PATTERN }
  validates :ip_address, presence: true, format: { with: IP_ADDRESS_PATTERN }
  validates :netmask, presence: true, format: { with: IP_ADDRESS_PATTERN }
  validates :gateway, presence: true, format: { with: IP_ADDRESS_PATTERN }
  validates :virtual_port_number, numericality: { only_integer: true, greater_than: 1 }
  validates :physical_port_number, numericality: { only_integer: true, greater_than: 1 }
  validates :vlan_id, numericality: { only_integer: true, greater_than: 0, less_than: 4096 }, allow_nil: true

  def initialize(attributes={})
    super
  end

end
