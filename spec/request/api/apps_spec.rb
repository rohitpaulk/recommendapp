require 'rails_helper'

describe "API", :type => :request do

  describe "GET /android_apps" do
    before do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:android_app)
    end

    it "lists all android apps" do
      get '/api/android_apps', { api_access_token: @user.api_access_token }
      expect(json.count).to eq(AndroidApp.count)
    end

    include_examples "auth", :get, '/api/android_apps'
  end

  describe "GET /android_apps/:id" do
    before do
      @user = FactoryGirl.create(:user)
      @app = FactoryGirl.create(:android_app)
    end

    it "fetches app details" do
      get "/api/android_apps/#{@app.id}", { api_access_token: @user.api_access_token }
      expect(json['display_name']).to eq(@app.display_name)
    end

    include_examples "auth", :get, '/api/android_apps/1'
  end
end
