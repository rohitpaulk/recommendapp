module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  shared_examples "auth" do |url|
    it "requires auth" do
      get url
      expect(response.status).to eq(401)
    end
  end
end
