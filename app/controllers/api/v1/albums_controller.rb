module Api
  module V1
    class AlbumsController < ApplicationController
      def index
        render json: Album.order(:id)
      end
    end
  end
end
