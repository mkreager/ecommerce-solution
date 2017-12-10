class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.belongs_to :album, null: false
      t.string :file_id, null: false
      t.string :file_filename, null: false
      t.integer :file_size, null: false
      t.string :file_content_type, null: false
      
      t.timestamps
    end
    add_foreign_key :photos, :albums
  end
end