module Api
  module V1
    class AlbumsController < ApplicationController
      def index
        render json: Album.get_albums(album_params)
      end

      private

      def album_params
        params.permit(:limit, :offset)
      end
    end
  end
end
