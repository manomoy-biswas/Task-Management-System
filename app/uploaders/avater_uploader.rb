class AvaterUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Process files as they are uploaded:
    process resize_to_fit: [800, 800]
 
  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fill:[40, 40]
  end
  version :small do
    process resize_to_fill:[250, 250]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(jpg jpeg png)
  end

  # Override the filename of the uploaded files:
  def filename
    "Profile_pivture_#{DateTime.now.strftime("%d%m%Y%I%M")}.jpg" if original_filename
  end
end
