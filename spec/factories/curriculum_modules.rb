FactoryBot.define do
  factory :curriculum_module do
    association :curriculum
    sequence(:title) { |n| "Module #{n}" }
    sequence(:position) { |n| n }
    module_type { :content }
    review_status { :unreviewed }
    content { {} }

    factory :quiz_module do
      module_type { :quiz }
      content do
        {
          "questions" => [
            {
              "id" => "q1",
              "text" => "What is 2+2?",
              "options" => ["3", "4", "5", "6"],
              "correct_answer" => "4",
              "explanation" => "Basic addition."
            },
            {
              "id" => "q2",
              "text" => "What color is the sky?",
              "options" => ["red", "blue", "green"],
              "correct_answer" => "blue",
              "explanation" => "The sky appears blue."
            },
            {
              "id" => "q3",
              "text" => "What is 3x3?",
              "options" => ["6", "9", "12"],
              "correct_answer" => "9",
              "explanation" => "Basic multiplication."
            },
            {
              "id" => "q4",
              "text" => "How many sides does a triangle have?",
              "options" => ["2", "3", "4"],
              "correct_answer" => "3",
              "explanation" => "A triangle has 3 sides."
            }
          ]
        }
      end
    end
  end
end
