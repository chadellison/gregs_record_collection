require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :request do
  describe 'GET /index' do
    it 'returns a 200 status on a successful call' do
      get '/api/v1/albums'

      expect(response.status).to eq 200
    end

    it 'returns all of the albums in the databse' do
      artist = Artist.create

      album_name = Faker::Name.first_name
      year = 1987
      Album.create(album_title: album_name, year: year, condition: 'excellent', artist: artist)

      album_name2 = Faker::Name.first_name
      year2 = 1999
      Album.create(album_title: album_name2, year: year2, condition: 'poor', artist: artist)

      get '/api/v1/albums'

      parsed_response = JSON.parse(response.body)

      expect(parsed_response[0]['album_title']).to eq album_name
      expect(parsed_response[1]['album_title']).to eq album_name2
    end
  end
end
