require 'rails_helper'

describe "API", :type => :request do

  describe "GET /recommendations" do
    before do
      @user = FactoryGirl.create(:user)
      2.times do
        FactoryGirl.create(:recommendation)
      end
      2.times do
        FactoryGirl.create(:recommendation, :recommender => @user)
      end
      1.times do
        FactoryGirl.create(:recommendation, :recommendee => @user)
      end
    end

    it "lists all recommendations" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token
      }
      expect(json.size).to eq(5)
    end

    it "filters recommendations by recommender_id" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommender_id: @user.id
      }
      expect(json.size).to eq(2)
      expect(json.first['recommender_id']).to eq(@user.id)
    end

    it "filters recommendations by recommendee_id" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_id: @user.id
      }
      expect(json.size).to eq(1)
      expect(json.first['recommendee_id']).to eq(@user.id)
    end

    include_examples "auth", :get, '/api/recommendations'
  end

  describe "POST /recommendations" do
    before do
      @user = FactoryGirl.create(:user)
      @other_user = FactoryGirl.create(:user)
      @app = FactoryGirl.create(:android_app)
    end

    it "creates a recommendation" do
      post '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_id: @other_user.id,
        item_id: @app.id,
        item_type: 'AndroidApp'
      }
      expect(Recommendation.count).to eq(1)
      expect(json['recommender_id']).to eq(@user.id)
    end

    it "returns 409 if recommendation exists" do
      reco = FactoryGirl.create(:recommendation, :recommender => @user)
      post '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_id: reco.recommendee.id,
        item_id: reco.item_id,
        item_type: reco.item_type
      }
      expect(Recommendation.count).to eq(1)
      expect(response.status).to eq(409)
    end

    include_examples "auth", :post, '/api/recommendations'
  end
end

