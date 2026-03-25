FactoryBot.define do
  factory :user do
    association :organization
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "Jane" }
    last_name { "Doe" }
    password { "password" }
    password_confirmation { "password" }
    role { :employee }

    factory :admin_user do
      role { :admin }
    end

    factory :manager_user do
      role { :manager }
    end

    factory :super_admin_user do
      role { :super_admin }
      association :organization, factory: :skill_block_organization
    end
  end
end
