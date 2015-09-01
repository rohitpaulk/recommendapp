require 'rails_helper'

describe "API", :type => :request do

  describe "GET /recommendations" do
    before do
      @user = FactoryGirl.create(:user)
      @other_user = FactoryGirl.create(:user)
      2.times do
        FactoryGirl.create(:recommendation)
      end
      2.times do
        FactoryGirl.create(:recommendation, :recommender => @user)
      end
      1.times do
        FactoryGirl.create(:recommendation, :recommendee => @user)
      end
      2.times do
        FactoryGirl.create(:recommendation, :recommender => @user, :recommendee => @other_user)
      end
    end

    it "lists all recommendations" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token
      }
      expect(json.size).to eq(7)
    end

    it "filters recommendations by recommender_id" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommender_id: @user.id
      }
      expect(json.size).to eq(4)
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

    it "can filter by multiple" do
      get '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommender_id: @user.id,
        recommendee_id: @other_user.id
      }
      expect(json.size).to eq(2)
      json.each do |item|
        expect(item['recommendee_id']).to eq(@other_user.id)
        expect(item['recommender_id']).to eq(@user.id)
      end
    end

    include_examples "auth", :get, '/api/recommendations'
  end

  describe "POST /recommendations" do
    before do
      @user = FactoryGirl.create(:user)
      @other_user = FactoryGirl.create(:user)
      @other_user2 = FactoryGirl.create(:user)
      @app = FactoryGirl.create(:android_app)
    end

    it "creates recommendations from ids" do
      post '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_ids: [@other_user.id, @other_user2.id],
        recommendee_emails: [],
        item_id: @app.id,
        item_type: 'AndroidApp'
      }
      expect(Recommendation.count).to eq(2)
    end

    # it "creates recommendations from emails" do
    #   post '/api/recommendations', {
    #     api_access_token: @user.api_access_token,
    #     recommendee_ids: [],
    #     recommendee_emails: [@other_user.email, @other_user2.email],
    #     item_id: @app.id,
    #     item_type: 'AndroidApp'
    #   }
    #   expect(json).to eq([{
    #     "errors" => ["Item has already been taken"]
    #   }])
    # end

    it "returns error message if recommendation exists" do
      reco = FactoryGirl.create(:recommendation, :recommender => @user)
      post '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_ids: [reco.recommendee.id],
        recommendee_emails: [],
        item_id: reco.item_id,
        item_type: reco.item_type
      }
      expect(Recommendation.count).to eq(1)
      expect(json).to eq([{
        "errors" => ["Item has already been taken"]
      }])
    end

    it "returns error message if recommending to self" do
      post '/api/recommendations', {
        api_access_token: @user.api_access_token,
        recommendee_ids: [@user.id],
        recommendee_emails: [],
        item_id: @app.id,
        item_type: 'AndroidApp'
      }
      expect(Recommendation.count).to eq(0)
      expect(json).to eq([{
        "errors" => ["You can't recommend items to yourself!"]
      }])
    end

    include_examples "auth", :post, '/api/recommendations'
  end

  describe "GET /recommendations/:id" do
    before do
      @user = FactoryGirl.create(:user)
      @recommendation = FactoryGirl.create(:recommendation)
    end

    it "fetches details of a recommendation" do
      get "/api/recommendations/#{@recommendation.id}", {
        api_access_token: @user.api_access_token
      }
      expect(json['recommendee_id']).to eq(@recommendation.recommendee_id)
      expect(json['recommender']).to be_a(Hash)
      expect(json['item']).to be_a(Hash)
    end

    include_examples "auth", :get, '/api/recommendations/1'
  end

  describe "PUT /recommendations/:id" do
    before do
      @user = FactoryGirl.create(:user)
      @recommendation = FactoryGirl.create(:recommendation)
    end

    it "modifies a recommendation" do
      put "/api/recommendations/#{@recommendation.id}", {
        api_access_token: @user.api_access_token,
        status: "seen"
      }
      expect(json['status']).to eq("seen")
      @recommendation.reload
      expect(@recommendation.status).to eq("seen")
    end

    include_examples "auth", :put, '/api/recommendations/1'
  end

end


