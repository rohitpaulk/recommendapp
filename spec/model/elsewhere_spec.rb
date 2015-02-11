require 'rails_helper'

describe Elsewhere do
  before do
    @user = FactoryGirl.create(:user)
  end

  it "has a valid factory" do
    expect(FactoryGirl.create(:elsewhere, :user => @user)).to be_valid
  end

  it "is not valid without a provider" do
    expect(FactoryGirl.build(:elsewhere, :user => @user, :provider => nil)).to_not be_valid
  end

  it "is not valid without a uid" do
    expect(FactoryGirl.build(:elsewhere, :user => @user, :uid => nil)).to_not be_valid
  end

  it "is not valid without an access_token" do
    expect(FactoryGirl.build(:elsewhere, :user => @user, :access_token => nil)).to_not be_valid
  end

  it "is unique on uid and provider" do
    elsewhere = FactoryGirl.create(:elsewhere, :user => @user)
    other_elsewhere = FactoryGirl.build(:elsewhere, :user => @user, :uid => elsewhere.uid, :provider => elsewhere.provider)
    expect(other_elsewhere).to_not be_valid
  end
end
