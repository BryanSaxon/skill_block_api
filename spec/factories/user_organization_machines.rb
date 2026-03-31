FactoryBot.define do
  factory :user_organization_machine do
    association :user
    association :organization_machine
  end
end
