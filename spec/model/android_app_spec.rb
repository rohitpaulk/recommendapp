require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(FactoryGirl.create(:android_app)).to be_valid
  end

  describe "validations" do
    it "is not valid without a uid" do
      expect(FactoryGirl.build(:android_app, :uid => nil)).to_not be_valid
    end

    it "is not valid without a display_name" do
      expect(FactoryGirl.build(:android_app, :display_name => nil)).to_not be_valid
    end

    it "is not valid with a duplicate uid" do
      app = FactoryGirl.create(:android_app)
      expect(FactoryGirl.build(:android_app, :uid => app.uid)).to_not be_valid
    end
  end

  it "can have many users" do
    app = FactoryGirl.create(:android_app)
    user1 = FactoryGirl.create(:user, :android_apps => [app])
    user2 = FactoryGirl.create(:user, :android_apps => [app])
    expect(app.users.count).to eq(2)
  end
end
