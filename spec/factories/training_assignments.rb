FactoryBot.define do
  factory :training_assignment do
    association :user
    association :curriculum
    association :organization_machine
    assigned_by { user }
    status { :not_started }
    due_date { 30.days.from_now }
  end
end
