require 'rails_helper'

describe "API", :type => :request do

  describe "GET /users" do
    it "lists all users" do
      user = FactoryGirl.create(:user)
      get '/api/users', {
        api_access_token: user.api_access_token
      }
      expect(json.count).to eq(User.count)
    end

    include_examples "auth", :get,  '/api/users'
  end

  describe "POST /users" do
    before do
      allow_any_instance_of(User).to receive(:update_movies_from_facebook).and_return([])
      allow_any_instance_of(User).to receive(:fetch_facebook_friends).and_return([])
      allow_any_instance_of(User).to receive(:update_facebook_avatar).and_return(nil)
    end

    it "creates user" do
      post '/api/users', {
        fb_uid: "uid1",
        fb_access_token: "access_token1",
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.count).to eq(1)
      expect(json["elsewheres"].size).to eq(1)
    end

    it "fetches friends from facebook if possible" do
      bill = FactoryGirl.create(:user)
      dorothy = FactoryGirl.create(:user)
      User.any_instance.unstub(:fetch_facebook_friends)
      expect_any_instance_of(User).to receive(:fetch_facebook_friends).and_return([bill, dorothy])
      post '/api/users', {
        fb_uid: '1379083422415077',
        fb_access_token: 'CAALBlziETAYBABFddZCvhWGCY6sDAGIk89Ey8v8K1aaDCsb3SR1r8U19wbQl5ZCuLCqKo2p8PkaDHueUfrJqZC8AFKn8RyTYgrrAYnjKq9rFsKjHQs7kKyJoFhZBL9bnzOdWbezrba9yZAA24Emya8gUrmEj8e8ivI7wTJcsWR5sRBk963aOyzZC7ThUvx0Qc3bMwLe20Soldd9DdtaqZBw',
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.count).to eq(3)
      expect(User.find(3).following.size).to eq(2)
    end

    it "calls update_facebook_avatar" do
      User.any_instance.unstub(:update_facebook_avatar)
      expect_any_instance_of(User).to receive(:update_facebook_avatar).once

      post '/api/users', {
        fb_uid: '1379083422415077',
        fb_access_token: 'CAALBlziETAYBABFddZCvhWGCY6sDAGIk89Ey8v8K1aaDCsb3SR1r8U19wbQl5ZCuLCqKo2p8PkaDHueUfrJqZC8AFKn8RyTYgrrAYnjKq9rFsKjHQs7kKyJoFhZBL9bnzOdWbezrba9yZAA24Emya8gUrmEj8e8ivI7wTJcsWR5sRBk963aOyzZC7ThUvx0Qc3bMwLe20Soldd9DdtaqZBw',
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }

      expect(User.count).to eq(1)
    end

    it "doesn't create user if elsewhere exists" do
      user = FactoryGirl.create(:user)
      post '/api/users', {
        fb_uid: user.elsewheres.first.uid,
        fb_access_token: user.elsewheres.first.uid,
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.count).to eq(1)
      expect(json["elsewheres"][0]["uid"]).to eq(user.elsewheres.first.uid)
    end

    it "rewrites access_token if elsewhere exists" do
      user = FactoryGirl.create(:user)
      post '/api/users', {
        fb_uid: user.elsewheres.first.uid,
        fb_access_token: 'new-access-token',
        email: "abcd@gmail.com",
        name: "Rohit Paul"
      }
      expect(User.first.elsewheres.first.access_token).to eq('new-access-token')
    end
  end

  describe "GET /users/:id" do
    before do
      @user = FactoryGirl.create(:user)
    end

    it "fetches details for user" do
      get "/api/users/#{@user.id}", {
        api_access_token: FactoryGirl.create(:user).api_access_token
      }
      expect(json["id"]).to eq(@user.id)
    end

    include_examples "auth", :get, "/api/users/1"
  end

  describe "GET /users/:id/friends" do
    before do
      @user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      @app1 = FactoryGirl.create(:android_app)

      @user = FactoryGirl.create(:user)
      @user.following += [@user1, user2]
    end

    it "fetches friends for user" do
      get "/api/users/#{@user.id}/friends", {
        api_access_token: @user.api_access_token
      }
      expect(json.size).to eq(2)
    end

    describe 'item filters' do

      it 'throws an error if item_type is invalid' do
        get "/api/users/#{@user.id}/friends", {
          api_access_token: @user.api_access_token,
          item_id: @app1.id,
          item_type: 'InvalidType'
        }
        expect(response.status).to eq(422)
        expect(response.body).to eq('Invalid item_type')
      end

      it 'checks if follower has item' do
        @user.following.first.android_apps << @app1
        get "/api/users/#{@user.id}/friends", {
          api_access_token: @user.api_access_token,
          item_id: @app1.id,
          item_type: 'AndroidApp'
        }
        expect(response.status).to eq(200)
        expect(json.size).to eq(2)
        expect(json[0]).to have_key('has_item')
        expect(json[0]['has_item']).to eq(true)
        expect(json[1]['has_item']).to eq(false)
      end

      it 'checks if user recommended the item to follower' do
        Recommendation.create(:recommender => @user,
                              :recommendee => @user1,
                              :item_type => 'AndroidApp',
                              :item_id => @app1.id)
        get "/api/users/#{@user.id}/friends", {
          api_access_token: @user.api_access_token,
          item_id: @app1.id,
          item_type: 'AndroidApp'
        }
        expect(response.status).to eq(200)
        expect(json.size).to eq(2)
        expect(json[0]).to have_key('has_been_recommended')
        expect(json[0]['has_been_recommended']).to eq(true)
        expect(json[1]['has_been_recommended']).to eq(false)
      end
    end

    include_examples "auth", :get, "/api/users/3/friends"
  end

  describe "GET /users/:id/android_apps" do
    let(:user) {
      FactoryGirl.create(:user,
        :android_apps => [
          FactoryGirl.create(:android_app),
          FactoryGirl.create(:android_app)
        ]
      )
    }

    it "returns all the users apps" do
      get "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token
      }
      expect(json.size).to eq(2)
    end

    include_examples "auth", :get, "/api/users/1/android_apps"
  end

  describe "GET /users/:id/movies" do
    let(:user) {
      FactoryGirl.create(:user)
    }

    it "returns 5 sample movies" do
      movies = 5.times.map { FactoryGirl.create(:movie, title: "Terminator") }
      expect(Movie).to receive(:popular_movies).once.and_return(movies)
      get "/api/users/#{user.id}/movies", {
        api_access_token: user.api_access_token
      }
      expect(json.size).to eq(5)
      expect(json.first["title"]).to eq('Terminator')
    end

    include_examples "auth", :get, "/api/users/1/movies"
  end


  describe "POST /users/:id/android_apps" do
    let(:user) { FactoryGirl.create(:user) }
    let(:valid_params) {
      [
          { uid: "1234", display_name: "Angry Birds" },
          { uid: "2345", display_name: "Temple Run" }
      ]
    }

    it "returns an error if apps array isn't provided" do
      post "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token
      }
      expect(response.status).to eq(400)
    end

    it "creates apps if they don't exist" do
      post "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        apps: valid_params
      }
      expect(json.size).to eq(2)
      expect(AndroidApp.count).to eq(2)
    end

    it "doesn't create apps again if they exist" do
      FactoryGirl.create(:android_app,
        uid: valid_params[0][:uid],
        display_name: valid_params[0][:display_name]
      )
      post "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        apps: valid_params
      }
      expect(AndroidApp.count).to eq(2)
    end

    it "returns only the number of apps updated" do
      app = FactoryGirl.create(:android_app,
        uid: valid_params[0][:uid],
        display_name: valid_params[0][:display_name]
      )
      user.android_apps = [app]
      user.save!
      post "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        apps: valid_params
      }
      expect(json.size).to eq(1)
    end

    it "doesn't let other users edit" do
      other_user = FactoryGirl.create(:user)
      post "/api/users/#{user.id}/android_apps", {
        api_access_token: other_user.api_access_token,
        apps: valid_params
      }
      expect(response.status).to eq(401)
    end

    include_examples "auth", :post, "/api/users/1/android_apps"
  end

  describe "DELETE /users/:id/android_apps" do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.android_apps.append(FactoryGirl.create(:android_app))
      user.save!
    end

    it "should delete the app from users#android_apps" do
      delete "/api/users/#{user.id}/android_apps", {
        api_access_token: user.api_access_token,
        uid: user.android_apps.first.uid
      }

      expect(response.status).to eq(200)
      expect(user.android_apps.count).to eq(0)
      expect(AndroidApp.count).to eq(1)
    end

    include_examples "auth", :delete, "/api/users/1/android_apps"
  end

  describe "PUT /users/:id" do
    let(:user) { FactoryGirl.create(:user) }

    it "updates push_id for user" do
      put "/api/users/#{user.id}", {
        api_access_token: user.api_access_token,
        push_id: "abcd"
      }
      expect(response.status).to eq(200)
      expect(json["push_id"]).to eq("abcd")
      user.reload
      expect(user.push_id).to eq("abcd")
    end

    it "doesn't let user change other user's ID" do
      put "/api/users/#{user.id}", {
        api_access_token: FactoryGirl.create(:user).api_access_token,
        push_id: "abcd"
      }
      expect(response.status).to eq(401)
    end

    include_examples "auth", :put, "/api/users/1"
  end
end

