FactoryBot.define do
  factory :organization_machine do
    association :organization
    association :machine
    sequence(:vin) { |n| "VIN-#{n}" }
    nickname { nil }
    status { "active" }
  end
end
