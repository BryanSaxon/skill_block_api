FactoryBot.define do
  factory :manufacturer do
    sequence(:name) { |n| "Manufacturer #{n}" }
  end
end
