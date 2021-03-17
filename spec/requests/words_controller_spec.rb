require 'rails_helper'

RSpec.describe "Words", type: :request do
  describe "GET /index" do
    it 'returns a 200 status' do
      get '/api/v1/words'

      expect(response.status).to eq 200
    end

    it 'returns the top ten words with the greatest word count in descending order' do
      multiplyer = 3

      12.times do |n|
        Word.create(word: n.to_s, count: n * multiplyer)
      end

      get '/api/v1/words'

      parsed_response = JSON.parse(response.body)

      expect(parsed_response.size).to eq 10
      expect(parsed_response.first['word']).to eq '11'
      expect(parsed_response.last['word']).to eq '2'
    end
  end
end
