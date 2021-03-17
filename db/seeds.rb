
artist = Artist.new(name: Faker::Name.first_name)

conditions = ['poor', 'fair', 'good', 'excellent']

puts 'creating albums'

30.times do |n|
  title = Faker::Name.first_name.downcase
  Album.create(
    album_title: title,
    artist: artist,
    year: rand(1902..2021),
    condition: conditions.sample
  )
  Word.update_word_counts({ new_title: title })
end

puts 'albums created'
