class Photo < ApplicationRecord
  belongs_to :album, counter_cache: true
  attachment :file, content_type: "image/jpeg"
  
  def change_filename
    self.file_filename = SecureRandom.base58 + '.jpg'
    save!
  end
    
  def process_image
    source = Bucket.object("store/original/#{file_id}")
              .presigned_url(:get, expires_in: 3600)
    full = Bucket.object("store/processed/albums/#{self.album_id}/full/#{file_filename}")
              .presigned_url(:put, expires_in: 3600)
    large = Bucket.object("store/processed/albums/#{self.album_id}/web/lg-#{file_filename}")
              .presigned_url(:put, expires_in: 3600, acl: 'public-read')
    medium = Bucket.object("store/processed/albums/#{self.album_id}/web/md-#{file_filename}")
              .presigned_url(:put, expires_in: 3600, acl: 'public-read')
    small = Bucket.object("store/processed/albums/#{self.album_id}/web/sm-#{file_filename}")
              .presigned_url(:put, expires_in: 3600, acl: 'public-read')
    
    blitline_service = Blitline.new
    blitline_service.add_job_via_hash({
      "application_id" => ENV["blitline_application_id"],
      "src" => "#{source}",
      "v" => 1.20,
      "wait_retry_delay" => 10,
      "postback_url" => "https://#{ENV["sksales_domain"]}/photos/#{id}/postback",
      "retry_postback" => true,
      "functions" => [
        {
          "name" => "no_op",
          "params" => {},
          "save"   => {
            "image_identifier" => "full",
            "s3_destination"   => { 
              "signed_url" => "#{full}",
              "headers" => {
                "Cache-Control" => "max-age=31536000, public",
                "Expires" => "Thu, 31 Dec 2026 16:00:00 GMT",
                "Content-Type" => "image/jpeg"
              }
            }, # push to your S3 bucket
          },
          "functions" => [
            {
              "name":"watermark",
              "params" => {
                "text" => "skphoto.ca",
                "point_size" => 500
              },
              "save"   => {
                "image_identifier" => "watermark",
                  "s3_destination"   => { "signed_url" => "#{large}" }
              },
              "functions" => [
                {
                  "name"   => "resize_to_fit", # resize after watermark
                  "params" => { 
                    "width" => 960, 
                    "height" => 960, 
                    "only_shrink_larger" => true, 
                    "autosharpen" => true 
                  },
                  "save"   => {
                    "image_identifier" => "large",
                    "s3_destination"   => { 
                      "signed_url" => "#{large}",
                      "headers" => {
                        "Cache-Control" => "max-age=31536000, public",
                        "Expires" => "Thu, 31 Dec 2026 16:00:00 GMT",
                        "Content-Type" => "image/jpeg"
                      }
                    }, # push to your S3 bucket
                  },
                  "functions" => [
                    {
                      "name"   => "resize_to_fit", # resize after watermark
                      "params" => { "width" => 640, "autosharpen" => true },
                      "save"   => {
                        "image_identifier" => "medium",
                        "s3_destination"   => { 
                          "signed_url" => "#{medium}",
                          "headers" => {
                            "Cache-Control" => "max-age=31536000, public",
                            "Expires" => "Thu, 31 Dec 2026 16:00:00 GMT",
                            "Content-Type" => "image/jpeg"
                          } 
                        }, # push to your S3 bucket
                      },
                      "functions" => [
                      	{
                          "name"   => "resize_to_fit", # resize after watermark
                          "params" => { "width" => 480, "autosharpen" => true },
                          "save"   => {
                            "image_identifier" => "small",
                            "s3_destination"   => { 
                              "signed_url" => "#{small}",
                              "headers" => {
                                "Cache-Control" => "max-age=31536000, public",
                                "Expires" => "Thu, 31 Dec 2026 16:00:00 GMT",
                                "Content-Type" => "image/jpeg"
                              } 
                            }, # push to your S3 bucket
                          }
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    })
    return blitline_service.post_jobs
  end
  
  def file_path_for_delete
    "store/original/#{file_id}"
  end
  
  def move_for_delete(file_id)
    file = Bucket.object(file_path_for_delete)
    file.move_to(Bucket.object("delete/#{file_id}"))
  end
  
  def lg_image_path
    "https://dsbnk6bwvegdp.cloudfront.net/store/processed/albums/#{self.album_id}/web/lg-#{file_filename}"
  end
  
  def md_image_path
    "https://dsbnk6bwvegdp.cloudfront.net/store/processed/albums/#{self.album_id}/web/md-#{file_filename}"
  end
  
  def sm_image_path
    "https://dsbnk6bwvegdp.cloudfront.net/store/processed/albums/#{self.album_id}/web/sm-#{file_filename}"
  end
  
end
