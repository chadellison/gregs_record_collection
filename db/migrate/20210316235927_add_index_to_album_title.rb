class AddIndexToAlbumTitle < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    enable_extension "btree_gin"

    add_index :albums, :album_title, using: :gin, algorithm: :concurrently
  end
end
