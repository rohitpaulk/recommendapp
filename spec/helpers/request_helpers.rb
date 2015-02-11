module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  shared_examples "auth" do |method, url|
    it "requires auth" do
      self.send(method, url)
      expect(response.status).to eq(401)
    end
  end
end
