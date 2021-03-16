require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :request do
  describe 'GET /index' do
    let(:artist) { Artist.create }

    let(:album_title1) { Faker::Name.first_name }
    let(:album_title2) { Faker::Name.first_name }

    let!(:album1) {
      Album.create(
        album_title: album_title1,
        year: 1984,
        condition: 'excellent',
        artist: artist
      )
    }

    let!(:album2) {
      Album.create(
        album_title: album_title2,
        year: 1999,
        condition: 'poor',
        artist: artist
      )
    }

    it 'returns a 200 status on a successful call' do
      get '/api/v1/albums'

      expect(response.status).to eq 200
    end

    it 'returns all of the albums in the databse' do
      get '/api/v1/albums'

      parsed_response = JSON.parse(response.body)

      expect(parsed_response[0]['album_title']).to eq album_title1
      expect(parsed_response[1]['album_title']).to eq album_title2
    end

    context 'when limit params are given' do
      it 'returns a paginated list of albums' do
        10.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums?limit=5'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq album_title1
        expect(parsed_response[1]['album_title']).to eq album_title2
        expect(parsed_response.size).to eq 5
      end
    end

    context 'when limit and offset params are given' do
      it 'returns a paginated list of offset albums' do
        10.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums?limit=5&offset=8'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq '6'
        expect(parsed_response.last['album_title']).to eq '9'
        expect(parsed_response.size).to eq 4
      end
    end

    context 'when no limit and no offset params are given' do
      it 'returns the first 10 records by default' do

        10.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq album_title1
        expect(parsed_response.last['album_title']).to eq '7'
        expect(parsed_response.size).to eq 10
      end
    end
  end
end
