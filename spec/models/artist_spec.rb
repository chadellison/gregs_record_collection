require 'rails_helper'

RSpec.describe Artist, type: :model do
  it 'has many albums' do
    expect(Artist.new).to respond_to :albums
  end
end
