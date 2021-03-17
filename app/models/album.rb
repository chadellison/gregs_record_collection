class Album < ApplicationRecord
  belongs_to :artist
  validates_presence_of :album_title
  validates_uniqueness_of :album_title, scope: :artist

  def self.get_albums(params)
    record_size = params[:limit].to_i
    limit = record_size > 0 ? record_size : 10

    query = Album.order(:id)
      .limit(limit)
      .offset(params[:offset].to_i)
      .includes(:artist)

    if params[:search].present?
      query = query.where("album_title LIKE ?", "%#{params[:search].downcase}%")
    end

    query
  end

  def self.create_album(params)
    album = build_album(params)
    handle_title('', album.album_title)
    save_album(album)
  end

  def self.build_album(params)
    artist_name = params[:artist] && params[:artist][:name]
    title = params[:album_title].to_s.downcase
    artist = Artist.find_or_create_by(name: artist_name.downcase)
    raise ActiveRecord::RecordInvalid unless artist.valid?

    artist.albums.new(
      album_title: title,
      year: params[:year],
      condition: params[:condition]
    )
  end

  def self.save_album(album)
    if album.save
      album
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def self.update_album(params)
    album = Album.find(params[:id])
    album.album_title = handle_title(album.album_title, params[:album_title].downcase)
    album.year = params[:year]
    album.condition = params[:condition]
    Artist.update_artist(params[:artist])
    save_album(album)
  end

  def self.handle_title(old_title, new_title)
    if old_title != new_title
      Word.update_word_counts({ old_title: old_title, new_title: new_title })
    end
    new_title
  end
end
