module Api
  module V1
    class AlbumsController < ApplicationController
      def index
        render json: Album.get_albums(filter_params)
      end

      def update
        Album.update_album(album_params)
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
