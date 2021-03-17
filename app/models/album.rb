class Album < ApplicationRecord
  belongs_to :artist

  def self.get_albums(params)
    limit = params[:limit].to_i > 0 ? params[:limit].to_i : 10

    query = Album.order(:id)
      .limit(limit)
      .offset(params[:offset].to_i)
      .includes(:artist)

    if params[:search].present?
      query = query.where("album_title LIKE ?", "%#{params[:search]}%")
    end

    query
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
