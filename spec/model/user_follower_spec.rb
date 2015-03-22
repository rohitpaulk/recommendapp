require 'rails_helper'

describe UserFollower do
  let(:user1) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }

  it "has a valid factory" do
    expect(FactoryGirl.create(:user_follower, :follower => user1, :following => user2)).to be_valid
  end

  it "is not valid without a follower" do
    expect(FactoryGirl.build(:user_follower, :follower => nil, :following => user2)).to_not be_valid
  end

  it "is not valid without a following" do
    expect(FactoryGirl.build(:user_follower, :follower => user1, :following => nil)).to_not be_valid
  end

  it "is not valid with a weird derived-from" do
    expect(FactoryGirl.build(:user_follower, :follower => user1, :following => user2, :derived_from => "facebook")).to be_valid
    expect(FactoryGirl.build(:user_follower, :follower => user1, :following => user2, :derived_from => "invalid")).to_not be_valid
  end

  it "is unique for given user and item" do
    FactoryGirl.create(:user_follower, :follower => user1, :following => user2)
    expect(FactoryGirl.build(:user_follower, :follower => user1, :following => user2)).to_not be_valid
  end
end

