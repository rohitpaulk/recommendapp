FactoryGirl.define do
  factory :recommendation do
    association :recommendee, factory: :user
    association :recommender, factory: :user
    association :item, factory: :android_app
  end
end
