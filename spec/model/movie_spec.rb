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

  # it "can have many users" do
  #   app = FactoryGirl.create(:android_app)
  #   user1 = FactoryGirl.create(:user, :android_apps => [app])
  #   user2 = FactoryGirl.create(:user, :android_apps => [app])
  #   expect(app.users.count).to eq(2)
  # end
end
