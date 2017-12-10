class CreateAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.belongs_to :user, null: false
      t.string :name, default: "Untitled Album"
      t.datetime :expiry_date
      t.boolean :paid, default: false
      t.integer  :user_id
      t.integer :photos_count

      t.timestamps
    end
    add_foreign_key :albums, :users
  end
end