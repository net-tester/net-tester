# frozen_string_literal: true

# Process model class
class ProcessValidator
  attr_accessor :host_name, :command, :initial_wait, :process_wait

  include ActiveModel::Model

  validates :host_name, presence: true
  validates :command, presence: true
  validates :initial_wait, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :process_wait, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def initialize(attributes = {})
    super
  end
end
