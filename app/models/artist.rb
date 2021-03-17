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
end
