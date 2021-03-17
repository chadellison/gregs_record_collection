require 'rails_helper'

RSpec.describe Artist, type: :model do
  it 'has many albums' do
    expect(Artist.new).to respond_to :albums
  end

  context 'when no name is present' do
    it 'is not valid' do
      artist = Artist.new
      expect(artist.valid?).to be false

      expected_error = { name: ['can\'t be blank'] }
      expect(artist.errors.messages).to eq expected_error
    end
  end

  describe 'update_artist' do
    it 'calls find on the Artist class' do
      artist = Artist.new
      expect(Artist).to receive(:find).with(1).and_return(artist)
      allow(Artist).to receive(:save_artist).and_return(artist)

      Artist.update_artist({ id: 1 })
    end

    it 'calls save_artist' do
      artist = Artist.new
      allow(Artist).to receive(:find).with(1).and_return(artist)
      expect(Artist).to receive(:save_artist).and_return(artist)

      Artist.update_artist({ id: 1 })
    end

    it 'returns the updated artist' do
      artist = Artist.new
      allow(Artist).to receive(:find).with(1).and_return(artist)
      allow(Artist).to receive(:save_artist).and_return(artist)

      expect(Artist.update_artist({ id: 1 })).to eq artist
    end
  end

  describe 'save_artist' do
    it 'calls save on the artist' do
      artist = Artist.new

      expect(artist).to receive(:save).and_return(true)

      Artist.save_artist(artist)
    end

    context 'when save returns true' do
      it 'returns the artist' do
        allow_any_instance_of(Artist).to receive(:save).and_return(true)

        artist = Artist.new

        expect(Artist.save_artist(artist)).to eq artist
      end
    end

    context 'when save returns false' do
      it 'raises an invalid record error' do
        allow_any_instance_of(Artist).to receive(:save).and_return(false)

        artist = Artist.new

        expect{
          Artist.save_artist(artist)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
