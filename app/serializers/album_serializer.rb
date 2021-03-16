class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :album_title, :condition, :year
  belongs_to :artist
end
