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

    include_examples "auth", '/api/android_apps'
  end
end
