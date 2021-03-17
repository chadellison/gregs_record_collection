module Api
  module V1
    class ArtistsController < ApplicationController
      def show
        artist = Artist.find(params[:id])
        render json: ArtistSerializer.serialize(artist)
      end
    end
  end
end
