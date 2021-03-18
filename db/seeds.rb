def create_artists
  puts 'creating artists'
  start = Time.now

  artists = []

  1000.times do |n|
    artists << Artist.new(name: Faker::Name.last_name)
  end

  Artist.import artists, validate: false

  end_time = Time.now
  puts "created 1000 artists in #{end_time - start} seconds"
  artists
end

def create_albums(artists, words)
  start = Time.now
  puts 'creating albums'

  conditions = ['poor', 'fair', 'good', 'excellent']
  albums = []
  artist = artists.sample

  100_000.times do |n|
    artist = artists.sample if n % 10 == 0
    if n % 20_000 == 0
      Album.import albums
      albums = []
    end

    title = Faker::Name.first_name.downcase[0..(rand(20))]
    album = Album.new(
      album_title: title,
      artist: artist,
      year: rand(1950..2021),
      condition: conditions.sample
    )
    albums << album

    if words[title]
      words[title] += 1
    else
      words[title] = 1
    end
  end

  Album.import albums
  end_time = Time.now
  puts "created #{Album.count} artists in #{end_time - start} seconds"
end

def create_words(words)
  start = Time.now
  puts 'creating words'

  word_objects = words.map do |word, count|
    Word.new(word: word, count: count)
  end

  Word.import word_objects, validate: false
  end_time = Time.now
  puts "created #{words.size} words in #{end_time - start} seconds"
end

artists = create_artists
words = {}

create_albums(artists, words)
create_words(words)
