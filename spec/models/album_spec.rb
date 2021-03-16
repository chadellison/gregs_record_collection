require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'belongs to an artist' do
    expect(Album.new).to respond_to :artist
  end

  context 'when no artist is present' do
    it 'is not valid' do
      album = Album.new
      expect(album.valid?).to be false

      expected_error = { artist: ['must exist'] }
      expect(album.errors.messages).to eq expected_error
    end
  end

  describe 'get_albums' do
    it 'calls order, limit, offset, and includes on the album and active record relation' do

      expect(Album).to receive(:order)
        .with(:id)
        .and_return(Album)

      expect(Album).to receive(:limit)
        .with(5)
        .and_return(Album)

      expect(Album).to receive(:offset)
        .with(3)
        .and_return(Album)

      expect(Album).to receive(:includes)
        .with(:artist)

      Album.get_albums({ limit: 5, offset: 3 })
    end
  end

  describe 'update_album' do
    context 'when the album is present' do
      it 'calls find on the Album class and save on an album and update_artist on Artist' do
        album = Album.new(
          id: 1,
          album_title: 'title',
          condition: 'condition',
          year: 1999,
        )

        expect(Album).to receive(:find).with(1).and_return(album)
        expect(Artist).to receive(:update_artist)

        expect(album).to receive(:save)

        artist_name = Faker::Name.first_name
        params = {
          id: 1,
          album_title: 'updated title',
          condition: 'updated condition',
          year: 2222,
          artist: { id: 3, name: artist_name }
        }

        Album.update_album(params)
      end
    end
  end
end
