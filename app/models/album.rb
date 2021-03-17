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
    album.album_title = handle_title(album.album_title, params[:album_title])
    album.year = params[:year]
    album.condition = params[:condition]
    Artist.update_artist(params[:artist])
    album.save
  end

  def self.handle_title(old_title, new_title)
    if old_title != new_title
      Word.update_word_counts({
        old_title: old_title,
        new_title: new_title
      })
    end
    new_title
  end
end
