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
    it 'calls order, limit and offset on the album and active record relation' do

      expect(Album).to receive(:order)
        .with(:id)
        .and_return(Album)

      expect(Album).to receive(:limit)
        .with(5)
        .and_return(Album)
        
      expect(Album).to receive(:offset)
        .with(3)

      Album.get_albums({ limit: 5, offset: 3 })
    end
  end
end
