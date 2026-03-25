FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }

    factory :skill_block_organization do
      name { Organization::SKILL_BLOCK_NAME }
    end
  end
end
