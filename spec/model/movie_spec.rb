require 'rails_helper'

describe Movie do
  it "has a valid factory" do
    expect(FactoryGirl.create(:movie)).to be_valid
  end

  describe "validations" do
    it "is not valid without an imdb_id" do
      expect(FactoryGirl.build(:movie, :imdb_id => nil)).to_not be_valid
    end

    it "is not valid without a Title" do
      expect(FactoryGirl.build(:movie, :title => nil)).to_not be_valid
    end

    it "is not valid with a duplicate uid" do
      movie = FactoryGirl.create(:movie)
      expect(FactoryGirl.build(:movie, :imdb_id => movie.imdb_id)).to_not be_valid
    end
  end

  it "can have many users" do
    movie = FactoryGirl.create(:movie)
    user1 = FactoryGirl.create(:user, :movies => [movie])
    user2 = FactoryGirl.create(:user, :movies => [movie])
    expect(movie.users.count).to eq(2)
  end

  describe "class methods" do
    describe "::from_title" do
      it "returns object if exists" do
        movie = FactoryGirl.create(:movie, :title => "Movie Exists")
        expect(Movie.from_title("Movie Exists")).to eq(movie)
      end

      it "fetches from tmdb if doesn't exist" do
        VCR.use_cassette('tmdb') do
          movie = Movie.from_title("The Terminator")
          expect(Movie.count).to eq(1)
          expect(movie.year).to eq("1984")
        end
      end
    end

    describe "::popular_movies" do
      it "yields values" do
        movie = FactoryGirl.create(:movie, :title => "Terminator")
        expect(Movie.popular_movies.first.title).to eq("Terminator")
      end
    end
  end
end
