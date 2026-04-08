FactoryBot.define do
  factory :curriculum do
    association :organization
    association :organization_machine
    sequence(:title) { |n| "Curriculum #{n}" }
    role_level { :entry }
    status { :published }
  end
end
