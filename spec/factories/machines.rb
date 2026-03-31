FactoryBot.define do
  factory :machine do
    association :manufacturer
    sequence(:name) { |n| "Machine #{n}" }
    sequence(:model_number) { |n| "MODEL-#{n}" }
    description { "A manufacturing machine" }
  end
end
