class Album < ApplicationRecord
  belongs_to :artist

  def self.get_albums(params)
    limit = params[:limit].present? ? params[:limit] : 10
    offset = params[:offset].present? ? params[:offset] : 0

    Album.order(:id).limit(limit).offset(offset).includes(:artist)
  end

  def self.update_album(params)
    album = Album.find(params[:id])
    album.album_title = params[:album_title]
    album.year = params[:year]
    album.condition = params[:condition]
    Artist.update_artist(params[:artist])
    album.save
  end
end
