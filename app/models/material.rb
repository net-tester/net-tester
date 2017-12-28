class Material

  include ActiveModel::Model

  attr_accessor :file

  validates :file, file_size: { greater_than: 0 }

  define_model_callbacks :save
  before_save :validate

  def initialize(attributes={})
    super
  end

  def self.all
    Dir.glob("#{NetTester.material_dir}/*").map do |path|
      File.basename(path)
    end.sort
  end

  def self.create(attributes={})
    Material.new(attributes).save
  end

  def save
    run_callbacks :save do
      FileUtils.mkdir_p(NetTester.material_dir)
      file = File.new("#{NetTester.material_dir}/#{@file.original_filename}", 'w+b')
      file.write @file.read
      file.close
    end
  end

  private

  def validate
    self.validate!
  end
end
