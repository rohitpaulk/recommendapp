FactoryGirl.define do
  factory :user do
    elsewheres { [FactoryGirl.build(:elsewhere)] }
  end
end
