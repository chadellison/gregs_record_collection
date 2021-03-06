require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'belongs to an artist' do
    expect(Album.new).to respond_to :artist
  end

  context 'when no artist is present' do
    it 'is not valid' do
      album = Album.new(album_title: 'title')
      expect(album.valid?).to be false

      expected_error = { artist: ['must exist'] }
      expect(album.errors.messages).to eq expected_error
    end
  end

  context 'when no album_title is present' do
    it 'is not valid' do
      artist = Artist.new
      album = artist.albums.new
      expect(album.valid?).to be false

      expected_error = { album_title: ['can\'t be blank'] }
      expect(album.errors.messages).to eq expected_error
    end
  end

  context 'when an album_title and artist already exists' do
    it 'is not valid' do
      artist = Artist.create(name: 'bob')
      album = artist.albums.create(album_title: 'abcs')
      album_duplicate = artist.albums.new(album_title: 'abcs')
      expect(album_duplicate.valid?).to be false

      expected_error = {:album_title=>["has already been taken"]}
      expect(album_duplicate.errors.messages).to eq expected_error
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

    context 'when the search parameter is present' do
      it 'calls where with the correct arguments' do
        allow(Album).to receive(:order)
          .with(:id)
          .and_return(Album)

        allow(Album).to receive(:limit)
          .with(10)
          .and_return(Album)

        allow(Album).to receive(:offset)
          .with(0)
          .and_return(Album)

        allow(Album).to receive(:includes)
          .with(:artist)
          .and_return(Album)

        expected1 = "album_title LIKE ?"
        expected2 = "%abc%"

        expect(Album).to receive(:where).with(expected1, expected2)

        Album.get_albums({ search: 'abc' })
      end
    end

    context 'when the search query is not present' do
      it 'does not call where on the active record relation' do
        allow(Album).to receive(:order)
          .with(:id)
          .and_return(Album)

        allow(Album).to receive(:limit)
          .with(10)
          .and_return(Album)

        allow(Album).to receive(:offset)
          .with(0)
          .and_return(Album)

        allow(Album).to receive(:includes)
          .with(:artist)
          .and_return(Album)

        expect(Album).not_to receive(:where)

        Album.get_albums({})
      end
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

        expect(album).to receive(:save).and_return(true)

        artist_name = Faker::Name.first_name
        params = {
          id: 1,
          album_title: 'updated title',
          condition: 'updated condition',
          year: 2222,
          artist: { id: 3, name: artist_name }
        }

        expect(Album).to receive(:handle_title)
          .with('title', 'updated title')

        Album.update_album(params)
      end
    end

    context 'when save returns false' do
      it 'raises an invalid record error' do
        album = Album.new
        allow(Album).to receive(:find).with(1).and_return(album)
        allow(Artist).to receive(:update_artist)

        allow(album).to receive(:save).and_return(false)

        artist_name = Faker::Name.first_name
        params = {
          id: 1,
          album_title: 'updated title',
          condition: 'updated condition',
          year: 2222,
          artist: { id: 3, name: artist_name }
        }

        allow(Album).to receive(:handle_title)

        expect {
          Album.update_album(params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'handle_title' do
    it 'returns the new title' do
      expect(Album.handle_title('title', 'title')).to eq 'title'
    end

    context 'when the album title is different from the given title' do
      it 'calls update_word_counts with the correct arguments' do
        expect(Word).to receive(:update_word_counts)
          .with({old_title: 'old title', new_title: 'new title'})
        Album.handle_title('old title', 'new title')
      end
    end

    context 'when the album title is the same as the given title' do
      it 'does not call perform_later' do

      end
    end
  end

  describe 'build_album' do
    it 'calls find_or_create_by on Artist with the correct arguments' do
      artist = Artist.new(name: 'bob')

      expect(Artist).to receive(:find_or_create_by)
        .with({ name: 'bob' })
        .and_return(artist)

      params = { artist: { name: 'bob' }, album_title: 'title' }

      Album.build_album(params)
    end

    it 'returns an album with the associated artist' do
      artist = Artist.create(name: 'bob')

      allow(Artist).to receive(:find_or_create_by)
        .with({ name: 'bob' })
        .and_return(artist)

      params = { artist: { name: 'bob' }, album_title: 'Title' }

      actual = Album.build_album(params)

      expect(actual.album_title).to eq 'title'
      expect(actual.artist).to eq artist
    end
  end

  describe 'create_album' do
    it 'calls build_album' do
      artist = Artist.new
      album = artist.albums.new

      params = { album_title: 'title' }

      expect(Album).to receive(:build_album).with(params).and_return(album)

      allow(album).to receive(:save).and_return(true)

      Album.create_album(params)
    end

    it 'calls save on a given album' do
      artist = Artist.new
      album = artist.albums.new

      params = { album_title: 'title' }

      allow(Album).to receive(:build_album).with(params).and_return(album)

      expect(album).to receive(:save).and_return(:true)

      Album.create_album(params)
    end

    context 'when save returns false' do
      it 'raises a bad request error' do
        artist = Artist.new
        album = artist.albums.new

        params = { album_title: 'title' }

        allow(Album).to receive(:build_album).with(params).and_return(album)

        allow(album).to receive(:save).and_return(false)

        expect{
          Album.create_album(params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when save returns true' do
      it 'calls handle_title with the correct arguments' do
        artist = Artist.new
        album = artist.albums.new(album_title: 'title')

        params = { album_title: 'title' }

        allow(Album).to receive(:build_album).with(params).and_return(album)

        allow_any_instance_of(Album).to receive(:save).and_return(:true)

        expect(Album).to receive(:handle_title).with('', 'title')

        Album.create_album(params)
      end

      it 'returns the saved album' do
        artist = Artist.new
        album = artist.albums.new(album_title: 'title')

        params = { album_title: 'title' }

        allow(Album).to receive(:build_album).with(params).and_return(album)

        allow_any_instance_of(Album).to receive(:save).and_return(:true)

        allow(Album).to receive(:handle_title).with('', 'title')

        expect(Album.create_album(params)).to eq album
      end
    end
  end
end
