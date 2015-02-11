FactoryGirl.define do
  sequence :uid do |n|
    "uid#{n}"
  end

  sequence :access_token do |n|
    "access_token#{n}"
  end

  factory :elsewhere do
    access_token { generate :access_token }
    provider "facebook"
    uid { generate :uid }
    # User can't be created here, circular dependency
  end
end
