require 'rails_helper'

RSpec.describe "Artists", type: :request do
  describe 'GET /show' do
    it 'returns a 200' do
      artist = Artist.create(name: Faker::Name.first_name)

      get "/api/v1/artists/#{artist.id}"

      expect(response.status).to eq 200
    end

    context 'when the artist exists' do
      it 'returns the artist with it\'s album counts released by year' do
        artist = Artist.create(name: Faker::Name.first_name)

        artist.albums.create(album_title: 'one', year: 1999)
        artist.albums.create(album_title: 'one more', year: 1999)
        artist.albums.create(album_title: 'one more time', year: 1999)
        artist.albums.create(album_title: 'another time', year: 2000)

        get "/api/v1/artists/#{artist.id}"

        parsed_response = JSON.parse(response.body)

        expect(parsed_response['id']).to eq artist.id
        expect(parsed_response['album_dates']['1999']).to eq 3
        expect(parsed_response['album_dates']['2000']).to eq 1
      end
    end

    context 'when the artist does not exist' do
      it 'returns a record not found' do
        expect{
          get '/api/v1/artists/0'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
