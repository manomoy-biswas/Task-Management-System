class DocumentUploader < CarrierWave::Uploader::Base
  
  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(jpg jpeg png doc docx pdf xls xml )
  end

  # Override the filename of the uploaded files:
  # def filename
  #   "#{file.filename.split(".").first}_#{DateTime.now.strftime("%d%m%Y%I%M%S").to_s + rand(100).to_s}.#{file.extension}" if original_filename.present?
  # end

  def size_range
    1.byte..50.megabytes
  end
end
