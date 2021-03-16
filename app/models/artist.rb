class Artist < ApplicationRecord
  has_many :albums

  def self.update_artist(params)
    artist = Artist.find(params[:id])
    artist.name = params[:name]
    artist.save
  end
end
