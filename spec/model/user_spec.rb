require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  describe "validations" do
    it "is not valid without an elsewhere" do
      expect(FactoryGirl.build(:user, elsewheres: [])).to_not be_valid
    end

    it "is creates an access_token if not present during validation" do
      user = FactoryGirl.build(:user, api_access_token: nil)
      expect(user.api_access_token).to eq(nil)
      user.valid?
      expect(user.api_access_token).to_not eq(nil)
    end

    it "is doesn't rewrite an access_token if present" do
      user = FactoryGirl.build(:user, api_access_token: "abcd")
      expect(user.api_access_token).to eq("abcd")
    end
  end

  it "can have many android apps" do
    app1 = FactoryGirl.create(:android_app)
    app2 = FactoryGirl.create(:android_app)
    user = FactoryGirl.create(:user, :android_apps => [app1, app2])
    expect(user.android_apps.count).to eq(2)
  end

  describe "#create_or_find_by_uid" do
    it "creates a new user if doesn't exist already" do
      User.create_or_find_by_uid("abcd1", {
        fb_access_token: "access_token",
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      })
      expect(User.count).to eq(1)
      expect(User.first.elsewheres.first.uid).to eq("abcd1")
    end
    it "fetches an existing user if exists" do
      user = FactoryGirl.create(:user)
      uid = user.elsewheres.first.uid
      User.create_or_find_by_uid(uid, {
        fb_access_token: "access_token",
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      })
      expect(User.count).to eq(1)
      expect(User.first.elsewheres.first.uid).to eq(uid)
    end
  end

  describe "#update_apps" do
    let(:user) { FactoryGirl.create(:user) }

    it "creates apps if they don't exist" do
      apps = [
        {
          uid: "1234",
          display_name: "Angry Birds"
        },
        {
          uid: "2345",
          display_name: "Temple Run"
        }
      ]
      user.update_apps(apps)
      expect(AndroidApp.count).to eq(2)
      expect(user.android_apps.count).to eq(2)
    end

    it "uses existing apps if they do exist" do
      app = FactoryGirl.create(:android_app)
      apps = [
        {
          uid: app.uid,
          display_name: app.display_name
        },
        {
          uid: "2345",
          display_name: "Temple Run"
        }
      ]
      user.update_apps(apps)
      expect(AndroidApp.count).to eq(2)
      expect(user.android_apps.count).to eq(2)
    end

    it "doesn't recreate user_items if they already exist" do
      apps = [
        {
          uid: "1234",
          display_name: "Angry Birds"
        },
        {
          uid: "2345",
          display_name: "Temple Run"
        }
      ]
      user.update_apps(apps)
      expect(AndroidApp.count).to eq(2)
      expect(user.android_apps.count).to eq(2)
      user.update_apps(apps)
      expect(AndroidApp.count).to eq(2)
      expect(user.android_apps.count).to eq(2)
    end
  end
end

