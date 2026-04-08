FactoryBot.define do
  factory :training_progress do
    association :training_assignment
    association :curriculum_module
    status { :not_started }
    quiz_answers { {} }
  end
end
