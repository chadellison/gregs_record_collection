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
end
