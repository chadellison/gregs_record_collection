class Album < ApplicationRecord
  belongs_to :artist

  def self.get_albums(params = { limit: 10, offset: 0 })
    limit = params[:limit].present? ? params[:limit] : 10
    offset = params[:offset].present? ? params[:offset] : 0

    Album.order(:id).limit(limit).offset(offset)
  end
end
