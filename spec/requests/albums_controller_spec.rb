require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :request do
  let(:artist_name) { Faker::Name.first_name }
  let(:artist) { Artist.create(name: artist_name) }

  let(:album_title1) { Faker::Name.first_name }
  let(:album_title2) { Faker::Name.first_name }

  describe 'GET /index' do
    it 'returns a 200 status on a successful call' do
      get '/api/v1/albums'

      expect(response.status).to eq 200
    end

    it 'returns albums from the databse' do
      Album.create(
        album_title: album_title1,
        year: 1984,
        condition: 'excellent',
        artist: artist
      )

      Album.create(
        album_title: album_title2,
        year: 1999,
        condition: 'poor',
        artist: artist
      )

      get '/api/v1/albums'

      parsed_response = JSON.parse(response.body)

      expect(parsed_response[0]['album_title']).to eq album_title1
      expect(parsed_response[1]['album_title']).to eq album_title2
    end

    it 'returns albums from the databse with the artist\'s name' do
      Album.create(
        album_title: album_title1,
        year: 1984,
        condition: 'excellent',
        artist: artist
      )

      get '/api/v1/albums'

      parsed_response = JSON.parse(response.body)

      expect(parsed_response[0]['artist']['name']).to eq artist_name
    end

    context 'when limit params are given' do
      it 'returns a paginated list of albums' do
        10.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums?limit=5'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq '0'
        expect(parsed_response[1]['album_title']).to eq '1'
        expect(parsed_response.size).to eq 5
      end
    end

    context 'when limit and offset params are given' do
      it 'returns a paginated list of offset albums' do
        12.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums?limit=5&offset=8'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq '8'
        expect(parsed_response.last['album_title']).to eq '11'
        expect(parsed_response.size).to eq 4
      end
    end

    context 'when no limit and no offset params are given' do
      it 'returns the first 10 records by default' do
        15.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums'

        parsed_response = JSON.parse(response.body)

        expect(parsed_response[0]['album_title']).to eq '0'
        expect(parsed_response.last['album_title']).to eq '9'
        expect(parsed_response.size).to eq 10
      end
    end

    context 'when the limit and offset params are invalid' do
      it 'disregards them' do
        10.times do |n|
          Album.create(album_title: n.to_s, artist: artist)
        end

        get '/api/v1/albums?limit=abc&offset=def'

        parsed_response = JSON.parse(response.body)

        expect(response.status).to eq 200
        expect(parsed_response[0]['album_title']).to eq '0'
        expect(parsed_response.last['album_title']).to eq '9'
        expect(parsed_response.size).to eq 10
      end
    end

    context 'when the params include a search parameter' do
      it 'returns albums that include the search query in their titles' do
        titles = ['money', 'amon', 'bob', 'harmony', 'other', 'things', 'the monday blues']

        titles.each do |title|
          Album.create(album_title: title, artist: artist)
        end

        get '/api/v1/albums?limit=20&offset=0&search=mon'

        parsed_response = JSON.parse(response.body)

        actual_album_titles = parsed_response.map do |album|
          album['album_title']
        end.sort

        expected_titles = ['money', 'amon', 'harmony', 'the monday blues'].sort

        expect(parsed_response.size).to eq 4
        expect(actual_album_titles).to eq expected_titles
      end
    end
  end

  describe 'PATCH /update' do
    let(:album_to_update) {
      Album.create(
        artist: artist,
        year: 2010,
        condition: 'good',
        album_title: 'title'
      )
    }

    it 'returns a 204 status when the record is correclty updated' do
      params = {
        id: album_to_update.id,
        year: 2010,
        condition: 'good',
        album_title: 'title',
        artist: {
          id: artist.id,
          name: artist.name
        }
      }
      patch "/api/v1/albums/#{album_to_update.id}", params: params

      expect(response.status).to eq 204
    end

    context 'when the album title is edited' do
      it 'updates the album title' do
        expected = 'much better title'
        params = {
          id: album_to_update.id,
          album_title: expected,
          year: 2010,
          condition: 'good',
          artist: {
            id: artist.id,
            name: 'bob jones'
          }
        }

        patch "/api/v1/albums/#{album_to_update.id}", params: params

        actual = Album.find(album_to_update.id).album_title

        expect(actual).to eq expected
      end
    end

    context 'when the other fields are updated' do
      it 'updates the other fields' do
        params = {
          id: album_to_update.id,
          album_title: ':)',
          year: 1983,
          condition: 'okay',
          artist: {
            id: artist.id,
            name: 'bob jones'
          }
        }

        patch "/api/v1/albums/#{album_to_update.id}", params: params

        actual = Album.find(album_to_update.id)

        expect(actual.album_title).to eq ':)'
        expect(actual.year).to eq 1983
        expect(actual.condition).to eq 'okay'
      end
    end

    context 'when the artist\'s name is updated' do
      it 'updates the artist\'s name' do
        expected_artist_name = Faker::Name.first_name

        params = {
          id: album_to_update.id,
          album_title: ':)',
          year: 1983,
          condition: 'okay',
          artist: {
            id: artist.id,
            name: expected_artist_name
          }
        }

        patch "/api/v1/albums/#{album_to_update.id}", params: params

        actual = Artist.find(artist.id)

        expect(actual.name).to eq expected_artist_name
      end
    end

    context 'when the album is not found' do
      it 'returns a 404 status with record not found' do
        expect{
          patch "/api/v1/albums/0", params: {}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the artist is not found' do
      it 'returns a 404 status with record not found' do
        expected_artist_name = Faker::Name.first_name

        params = {
          id: album_to_update.id,
          album_title: ':)',
          year: 1983,
          condition: 'okay',
          artist: {
            id: 0,
            name: expected_artist_name
          }
        }

        expect{
          patch "/api/v1/albums/#{album_to_update.id}", params: params
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
