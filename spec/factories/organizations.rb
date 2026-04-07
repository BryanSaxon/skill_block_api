FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
    org_type { :client }

    factory :skill_block_organization do
      name { Organization::SKILL_BLOCK_NAME }
      org_type { :admin }
    end
  end
end
