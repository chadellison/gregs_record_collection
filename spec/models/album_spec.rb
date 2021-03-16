require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'belongs to an artist' do
    expect(Album.new).to respond_to :artist
  end
end
