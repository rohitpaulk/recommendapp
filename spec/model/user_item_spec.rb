require 'rails_helper'

describe UserItem do
  before do
    @user = FactoryGirl.create(:user)
    @app = FactoryGirl.create(:android_app)
  end

  it "has a valid factory" do
    expect(FactoryGirl.create(:user_item, :user => @user, :item => @app)).to be_valid
  end

  it "is not valid without a user" do
    expect(FactoryGirl.build(:user_item, :user => nil, :item => @app)).to_not be_valid
  end

  it "is not valid without an item" do
    expect(FactoryGirl.build(:user_item, :user => @user, :item => nil)).to_not be_valid
  end

  it "is unique for given user and item" do
    FactoryGirl.create(:user_item, :user => @user, :item => @app)
    expect(FactoryGirl.build(:user_item, :user => @user, :item => @app)).to_not be_valid
  end
end

