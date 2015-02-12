describe Recommendation do
  it "has a valid factory" do
    expect(FactoryGirl.create(:recommendation)).to be_valid
  end

  it "isn't valid without a recommendee" do
    expect(FactoryGirl.build(:recommendation, :recommendee => nil)).to_not be_valid
  end

  it "isn't valid without a recommender" do
    expect(FactoryGirl.build(:recommendation, :recommender => nil)).to_not be_valid
  end

  it "isn't valid without an item" do
    expect(FactoryGirl.build(:recommendation, :item => nil)).to_not be_valid
  end

  it "sets pending status if not provided" do
    reco = FactoryGirl.build(:recommendation, :status => nil)
    reco.valid?
    expect(reco.status).to eq('pending')
  end

  it "isn't valid with same recommender and recommendee" do
    user = FactoryGirl.create(:user)
    expect(FactoryGirl.build(:recommendation, :recommender => user, :recommendee => user)).to_not be_valid
  end

  it "is unique for recommendee, recommender and item" do
    reco = FactoryGirl.create(:recommendation)
    expect(FactoryGirl.build(:recommendation,
      :recommender => reco.recommender,
      :recommendee => reco.recommendee,
      :item => reco.item
    )).to_not be_valid
  end

end