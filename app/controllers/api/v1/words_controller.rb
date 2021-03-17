module Api
  module V1
    class WordsController < ApplicationController
      def index
        render json: Word.order(count: :desc).limit(10)
      end
    end
  end
end
