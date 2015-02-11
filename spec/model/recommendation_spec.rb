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
end
