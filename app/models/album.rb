class Album < ApplicationRecord
  belongs_to :user
  has_many :photos, dependent: :destroy
  accepts_attachments_for :photos
  
  def album_file_name
    [name.parameterize].join("-") + ".zip"
  end
  
  def files_for_zip
    files = []
    self.photos.each do |p|
      files << Aws::S3::Presigner.new.presigned_url(
          :get_object, 
          bucket: "skphoto.sales", 
          key: "store/processed/albums/#{id}/full/#{p.file_filename}")
    end
    files
  end
  
  def process_album_zip
    blitline_service = Blitline.new
    blitline_service.add_job_via_hash({
      "application_id" => ENV["blitline_application_id"],
      "src" => {
        "urls" => files_for_zip
      },
      "src_type" => "zip",
      #"postback_url" => "http://www.blitline.com/stats",
      "src_data" => {
        "s3_destination" => {
            "bucket" => "skphoto.sales",
            "key" => "store/processed/albums/#{id}/full/zip/#{album_file_name}"
        }
      }
    })
    return blitline_service.post_jobs
  end
  
  def get_zip
    Bucket.object("store/processed/albums/#{id}/full/zip/#{album_file_name}")
          .presigned_url(:get, expires_in: 3600)
  end
end