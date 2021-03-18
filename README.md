# README

## Greg's album collection
A rest API for managing all of Greg's records

### Use
search all of Greg's albums in paginated fashion with the 'limit' and 'offset' params
```
GET localhost:3000/api/v1/albums?limit=100&offset=30000
```
returns an array of 100 albums offset by 30000 with their associated artist

![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/albums_pagination.png)

If no params are given, a default of 10 albums will be returned with 0 offset
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/albums_no_params.png)

Greg's albums can also be searched by album title with a 'search' param. For example:
```
GET localhost:3000/api/v1/albums?search=os
```
will return albums with 'os' anywhere in their title (case insensitive)
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/albums_search.png)

these params can also be combined with the limit and offset
```
GET localhost:3000/api/v1/albums?limit=1000&offset=0&search='Ja'
```
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/albums_all_params.png)

Greg's albums can also be updated like so:

```
PATCH localhost:3000/api/v1/albums/33

{
        "id": 33,
        "album_title": "no longer jada",
        "condition": "rough",
        "year": 1957,
        "artist": {
            "id": 19,
            "name": "Erin",
            "created_at": "2021-03-17T23:41:09.344Z",
            "updated_at": "2021-03-17T23:41:09.344Z"
        }
}
```
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/update_album.png)

The album_title, condition, year, and artist's name fields can all be updated

We can also add to Greg's albums like so:

```
POST localhost:3000/api/v1/albums

{
    "album_title": "this new thing",
    "condition": "excellent",
    "year": 1965,
    "artist": {
        "name": "unknown"
    }
}
```
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/create_album.png)

additions must have a unique combination of album_title and artist name

For example, if we try to create the same album twice we will get a 422 error:

We can also view the most commonly used words from the album titles across the entire collection
```
GET localhost:3000/api/v1/words
```
returns an array of the 10 most commonly used words and their respective counts
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/words_request.png)

We can also see the number of albums an artist released each each year with the following:

```
GET localhost:3000/api/v1/artists/807
```
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/artist_with_album_release_counts.png)

###To run the application locally:
run the following commands from the command line

```
git clone https://github.com/chadellison/gregs_record_collection.git
```
run bundle
```
bundle
```

create the database
```
rake db:create
```

run the migrations
```
rake db:migrate
```

run the seed file
```
rake db:seed
```
the seed file will load 1000 artists and 100_000 albums
this should finish in less than a minute

Since we know Greg will have 1 million albums any day now, we can update
the seed file to write 1 million albums to the database (this should take roughly 7 minutes)
![ScreenShot](https://raw.github.com/chadellison/gregs_record_collection/master/public/artist_with_album_release_counts.png)

key word searches across the entire album collection should still be sub 500 ms 👍

the server can be started with ```rails s```

the test suite can be run with ```rspec```

ruby version 2.7.1
