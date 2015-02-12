FactoryGirl.define do
  factory :user do
    elsewheres { [FactoryGirl.build(:elsewhere)] }
    push_id "abcd"
  end
end
