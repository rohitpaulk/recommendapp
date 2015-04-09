FactoryGirl.define do
  sequence :movie_imdb_id do |n|
    "imdb#{n}"
  end

  sequence :movie_title do |n|
    "Movie Title#{n}"
  end

  factory :movie do
    imdb_id { generate :app_uid }
    title { generate :movie_title }
  end
end
