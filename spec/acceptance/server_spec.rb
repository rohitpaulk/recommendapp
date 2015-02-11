require 'rails_helper'

describe "Server", :type => :feature do
  it "says Hello World" do
    visit '/'
    expect(page).to have_text("Hello World")
  end
end
