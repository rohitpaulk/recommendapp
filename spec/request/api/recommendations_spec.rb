require 'rails_helper'

describe "API", :type => :request do

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

    include_examples "auth", :post, '/api/recommendations'
  end
end

