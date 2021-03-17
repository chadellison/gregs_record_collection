module Api
  module V1
    class AlbumsController < ApplicationController
      def index
        render json: Album.get_albums(filter_params)
      end

      def create
        render json: Album.create_album(album_params), status: 201
      end

      def update
        render json: Album.update_album(album_params)
      end

      private

      def filter_params
        params.permit(:limit, :offset, :search)
      end

      def album_params
        params.permit(:id, :album_title, :year, :condition, artist: {})
      end
    end
  end
end
