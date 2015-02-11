FactoryGirl.define do
  sequence :app_uid do |n|
    "app_uid#{n}"
  end

  sequence :display_name do |n|
    "display name#{n}"
  end
  factory :android_app do
    uid { generate :app_uid }
    display_name { generate :display_name }
  end
end
