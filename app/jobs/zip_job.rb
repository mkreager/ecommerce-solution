class ZipJob
  include SuckerPunch::Job

  def perform(id)
    ActiveRecord::Base.connection_pool.with_connection do
      album = Album.find(id)
      album.process_album_zip
    end
  end
end