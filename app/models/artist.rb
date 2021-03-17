class Artist < ApplicationRecord
  has_many :albums
  validates_presence_of :name

  def self.update_artist(params)
    artist = Artist.find(params[:id])
    artist.name = params[:name]
    save_artist(artist)
  end

  def self.save_artist(artist)
    if artist.save
      artist
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  def albums_released_by_year
    album_counts = {}
    albums.each do |album|
      year = album.year
      if album_counts[year].present?
        album_counts[year] += 1
      else
        album_counts[year] = 1
      end
    end

    album_counts
  end
end
