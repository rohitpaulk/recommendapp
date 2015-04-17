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

  describe "associations" do
    it "can have many android apps" do
      movie1 = FactoryGirl.create(:movie)
      movie2 = FactoryGirl.create(:movie)
      user = FactoryGirl.create(:user, :movies => [movie1, movie2])
      expect(user.movies.count).to eq(2)
    end

    it "can have many movies" do
      app1 = FactoryGirl.create(:android_app)
      app2 = FactoryGirl.create(:android_app)
      user = FactoryGirl.create(:user, :android_apps => [app1, app2])
      expect(user.android_apps.count).to eq(2)
    end
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

    it "updates recommendation status" do
      app = FactoryGirl.create(:android_app)
      recommendation = FactoryGirl.create(:recommendation,
        :recommender => FactoryGirl.create(:user),
        :recommendee => user,
        :item => app
      )
      user.update_apps([app])
      recommendation.reload
      expect(recommendation.status).to eq("successful")
    end
  end

  describe "#send_notification" do
    let(:user) { FactoryGirl.create(:user) }

    it "sends notification to push_id" do
      expect(GCM).to receive(:send_notification).with(user.push_id, {abcd: "hey"})
      user.send_notification({abcd: "hey"})
    end

    it "doesn't send if push_id is nil" do
      user_without_push = FactoryGirl.create(:user, :push_id => nil)
      expect(GCM).to_not receive(:send_notification)
      user_without_push.send_notification({abcd: "hey"})
    end
  end

  describe "#fetch_facebook_movies" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.elsewheres.delete_all
      FactoryGirl.create(:elsewhere,
        user: user,
        provider: 'facebook',
        uid: '10202390662768085',
        access_token: 'CAALBlziETAYBAAhOerbeSJ187pLVSfDQUlnZAaTL4RDbbSpnahlGO2ZADDaqUkRZAOozRmiC2DUq6wJBbywEIlG1WOkQZBim8BClpYJwywNZAE5fAa4J9ooDsaG8ILXDLxppZB73fbOBjJ6RxsAjmfXrZBY8KYHPWfr8BJUH1T7qjyizkCUfyp0ZBlm6uNoB2wboKjIhrohkjZAJaZBcadbriiXVhezBBdgZBcXCgH8ST8mxrqEqD1QAFZB7'
      )
    end

    it "lists facebook movies for a user" do
      VCR.use_cassette("facebook-movies") do
        response = user.fetch_facebook_movies
        expect(response.size).to eq(25)
        expect(response.first.category).to eq("Movie")
      end
    end
  end

  describe "#update_facebook_avatar" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.elsewheres.delete_all
      FactoryGirl.create(:elsewhere,
        user: user,
        provider: 'facebook',
        uid: '10202390662768085',
        access_token: 'CAALBlziETAYBAAhOerbeSJ187pLVSfDQUlnZAaTL4RDbbSpnahlGO2ZADDaqUkRZAOozRmiC2DUq6wJBbywEIlG1WOkQZBim8BClpYJwywNZAE5fAa4J9ooDsaG8ILXDLxppZB73fbOBjJ6RxsAjmfXrZBY8KYHPWfr8BJUH1T7qjyizkCUfyp0ZBlm6uNoB2wboKjIhrohkjZAJaZBcadbriiXVhezBBdgZBcXCgH8ST8mxrqEqD1QAFZB7'
      )
    end
        
    it "Updates the user's facebook avatar" do
      VCR.use_cassette("facebook-avatar") do
        user.update_facebook_avatar
        expect(user.avatar_url).not_to be_nil
      end
    end
  end

  describe "Facebook friends" do
    let(:user) { FactoryGirl.create(:user) }
    let(:bill) { FactoryGirl.create(:user) }
    let(:dorothy) { FactoryGirl.create(:user) }

    before do
      user.elsewheres.delete_all
      bill.elsewheres.delete_all
      dorothy.elsewheres.delete_all
      # Create Jennifer
      FactoryGirl.create(:elsewhere,
        user: user,
        provider: 'facebook',
        uid: '1379083422415077',
        access_token: 'CAALBlziETAYBABFddZCvhWGCY6sDAGIk89Ey8v8K1aaDCsb3SR1r8U19wbQl5ZCuLCqKo2p8PkaDHueUfrJqZC8AFKn8RyTYgrrAYnjKq9rFsKjHQs7kKyJoFhZBL9bnzOdWbezrba9yZAA24Emya8gUrmEj8e8ivI7wTJcsWR5sRBk963aOyzZC7ThUvx0Qc3bMwLe20Soldd9DdtaqZBw'
      )
      # Create Bill
      FactoryGirl.create(:elsewhere,
        user: bill,
        provider: 'facebook',
        uid: '1382918175363337',
        access_token: 'dummy'
      )
      # Create Dorothy
      FactoryGirl.create(:elsewhere,
        user: dorothy,
        provider: 'facebook',
        uid: '1384583518529366',
        access_token: 'dummy'
      )
    end

    describe "#fetch_facebook_friends" do
      it "lists facebook friends for a user" do
        VCR.use_cassette("facebook") do
          response = user.fetch_facebook_friends
          expect(response.size).to eq(2)
          expect(response).to match_array([bill, dorothy])
        end
      end
    end

    describe "#update_facebook_friends" do
      it "Updates the user's friends" do
        expect(user).to receive(:fetch_facebook_friends).and_return([bill, dorothy])
        user.update_facebook_friends
        expect(user.following).to match_array([bill, dorothy])
      end
    end
  end

  describe "#following" do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }

    it "Lists users one follows" do
      expect(user1.following).to be_empty
      user1.following << user2
      expect(user1.following).to eq([user2])
    end
  end
end

