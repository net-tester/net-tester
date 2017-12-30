# frozen_string_literal: true

# Testlet model class
class Testlet
  include ActiveModel::Model

  attr_accessor :file

  validates :file, file_size: { greater_than: 0 }

  define_model_callbacks :save
  before_save :validate

  def initialize(attributes = {})
    super
  end

  def self.all
    Dir.glob("#{NetTester.testlet_dir}/*").map do |path|
      File.basename(path)
    end.sort
  end

  def self.create(attributes = {})
    Testlet.new(attributes).save
  end

  def save
    run_callbacks :save do
      FileUtils.mkdir_p(NetTester.testlet_dir)
      file = File.new("#{NetTester.testlet_dir}/#{@file.original_filename}", 'w+b')
      file.write @file.read
      file.close
    end
  end

  private

  def validate
    validate!
  end
end
