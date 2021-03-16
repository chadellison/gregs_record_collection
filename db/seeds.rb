
artist = Artist.new(name: Faker::Name.first_name)

conditions = ['poor', 'fair', 'good', 'excellent']

puts 'creating albums'

30.times do |n|
  Album.create(
    album_title: Faker::Name.first_name,
    artist: artist,
    year: rand(1902..2021),
    condition: conditions.sample
  )
end

puts 'albums created'
