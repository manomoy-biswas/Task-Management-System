class DocumentUploader < CarrierWave::Uploader::Base
  
  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(jpg jpeg png doc docx pdf xls xml )
  end

  # Override the filename of the uploaded files:
  def filename
    id = 0
    id = TaskDocument.last.id if TaskDocument.last.present?
    @name ||= "DOC_TD_#{id  + 1}#{DateTime.now.strftime("%d%m%Y%I%M%S")}.#{file.extension}" if original_filename.present?
  end

  def size_range
    1.byte..50.megabytes
  end
end
