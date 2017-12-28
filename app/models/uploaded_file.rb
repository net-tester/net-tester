class UploadedFile

  include ActiveModel::Model

  attr_accessor :source

  validates :source, file_size: { greater_than: 0 }

  define_model_callbacks :save
  before_save :validate

  def initialize(attributes={})
    super
  end

  def self.all
    Dir.glob("#{NetTester.upload_dir}/*").map do |path|
      File.basename(path)
    end.sort
  end

  def self.create(attributes={})
    UploadedFile.new(attributes).save
  end

  def save
    run_callbacks :save do
      file = File.new("#{NetTester.upload_dir}/#{@source.original_filename}", 'w+b')
      file.write @source.read
      file.close
    end
  end

  private

  def validate
    self.validate!
  end
end
