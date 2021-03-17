require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :request do
  let(:artist_name) { Faker::Name.first_name }
  let(:artist) { Artist.create(name: artist_name) }
  let!(:word) { Word.create(word: 'title', count: 1) }
  let!(:old_word) { Word.create(word: 'old-title') }

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

    context 'when the params include a search parameter that is capitalized' do
      it 'returns albums that include the search query in their titles regardless of case' do
        titles = ['money', 'amon', 'bob', 'harmony', 'other', 'things', 'the monday blues']

        titles.each do |title|
          Album.create(album_title: title, artist: artist)
        end

        get '/api/v1/albums?limit=20&offset=0&search=MoN'

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

    it 'returns a 200 status when the record is correclty updated' do
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

      expect(response.status).to eq 200
    end

    it 'returns the updated resource' do
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

      parsed_response = JSON.parse(response.body)

      expect(parsed_response['album_title']).to eq 'title'
      expect(parsed_response['artist']['name']).to eq artist_name
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

      context 'when there are new words in the word title' do
        it 'updates the word counts in the words' do
          params = {
            id: album_to_update.id,
            album_title: 'much better name',
            year: 2010,
            condition: 'good',
            artist: {
              id: artist.id,
              name: 'bob jones'
            }
          }

          expect {
            patch "/api/v1/albums/#{album_to_update.id}", params: params
          }.to change { Word.count }.by(3)

          word1 = Word.find_by(word: 'much')
          word2 = Word.find_by(word: 'better')
          word3 = Word.find_by(word: 'name')

          expect(word1.count).to eq 1
          expect(word2.count).to eq 1
          expect(word3.count).to eq 1
        end
      end

      context 'when there are not new words in the word title' do
        it 'does not update the word count' do
          params = {
            id: album_to_update.id,
            album_title: 'old-title',
            year: 2010,
            condition: 'good',
            artist: {
              id: artist.id,
              name: 'bob jones'
            }
          }

          expect {
            patch "/api/v1/albums/#{album_to_update.id}", params: params
          }.to change { Word.count }.by(0)

          word = Word.find_by(word: 'old-title')

          expect(word.count).to eq 1
        end
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

  describe 'POST /create' do
    it 'returns a 201 status' do
      title = Faker::Name.first_name
      params = { album_title: title, artist: { name: 'bob' } }

      post '/api/v1/albums', params: params

      expect(response.status).to eq 201
    end

    it 'creates an album' do
      title = Faker::Name.first_name
      params = { album_title: title, artist: { name: 'bob' } }

      expect{
        post '/api/v1/albums', params: params
      }.to change { Album.count }.by(1)
    end

    it 'returns the created album' do
      title = Faker::Name.first_name
      params = { album_title: title, artist: { name: 'bob' } }

      post '/api/v1/albums', params: params

      parsed_response = JSON.parse(response.body)

      expect(parsed_response['album_title']).to eq title.downcase
      expect(parsed_response['artist']['name']).to eq 'bob'
    end

    context 'when the artist does not exist' do
      it 'creates an artist' do
        title = Faker::Name.first_name
        params = { album_title: title, artist: { name: 'bob' } }

        expect{
          post '/api/v1/albums', params: params
        }.to change { Artist.count }.by(1)
        expect(Artist.find_by(name: 'bob')).to be_present
      end
    end

    context 'when the artist already exists' do
      it 'does not create an artist' do
        title = Faker::Name.first_name
        artist = Artist.create(name: 'bob')
        params = { album_title: title, artist: { name: 'bob' } }

        expect{
          post '/api/v1/albums', params: params
        }.not_to change { Artist.count }
      end
    end

    context 'when the word does not exist' do
      it 'creates a word with a count of one' do
        title = Faker::Name.first_name
        params = { album_title: title, artist: { name: 'bob' } }

        expect{
          post '/api/v1/albums', params: params
        }.to change { Word.count }.by(1)
      end
    end

    context 'when the word does exist' do
      it 'increments it\'s count and does not add the word' do
        word_name = Faker::Name.first_name.downcase

        word = Word.create(word: word_name, count: 1)
        params = { album_title: word_name, artist: { name: 'bob' } }

        expect{
          post '/api/v1/albums', params: params
        }.not_to change { Word.count }

        expect(Word.find_by(word: word_name).count).to eq 2
      end
    end

    context 'when the album is invalid' do
      context 'when the album title is empty' do
        it 'raises a record invalid error' do
          params = { album_title: '', artist: { name: 'bob' } }

          expect{
            post '/api/v1/albums', params: params
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the album title is nil' do
        it 'raises a record invalid error' do
          params = { album_title: nil, artist: { name: 'bob' } }

          expect{
            post '/api/v1/albums', params: params
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the artist name is empty' do
        it 'raises a record invalid error' do
          params = { album_title: 'this is the title', artist: { name: '' } }

          expect{
            post '/api/v1/albums', params: params
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the artist and album_title already exist' do
        it 'raises a record invalid error' do
          artist = Artist.create(name: 'bob')
          artist.albums.create(album_title: 'duplicate')

          params = { album_title: 'duplicate', artist: { name: 'bob' } }

          expect{
            post '/api/v1/albums', params: params
            expect(repsonse.status).to eq 422
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
