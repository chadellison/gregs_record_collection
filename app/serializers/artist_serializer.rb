class ArtistSerializer
  def self.serialize(artist)
    {
      id: artist.id,
      name: artist.name,
      album_dates: artist.albums_released_by_year
    }
  end
end
