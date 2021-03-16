class CreateAlbums < ActiveRecord::Migration[6.0]
  def change
    create_table :albums do |t|
      t.integer :artist_id
      t.string :album_title
      t.integer :year
      t.string :condition
      t.timestamps
    end
  end
end
