json.extract! album, :id, :name, :expiry_date, :created_at, :updated_at
json.url album_url(album, format: :json)
