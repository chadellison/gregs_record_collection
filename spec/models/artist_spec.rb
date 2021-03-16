require 'rails_helper'

RSpec.describe Artist, type: :model do
  it 'has many albums' do
    expect(Artist.new).to respond_to :albums
  end

  describe 'update_artist' do
    it 'calls find on the Artist class and save on an instance of artist' do
      artist = Artist.new
      expect(Artist).to receive(:find).with(1).and_return(artist)
      expect_any_instance_of(Artist).to receive(:save)

      Artist.update_artist({ id: 1 })
    end
  end
end
