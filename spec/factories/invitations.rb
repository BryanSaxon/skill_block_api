FactoryBot.define do
  factory :invitation do
    sequence(:email) { |n| "invite#{n}@example.com" }
    role { :operator }
    association :organization
    association :invited_by, factory: :admin_org_user
    expires_at { 48.hours.from_now }

    trait :expired do
      expires_at { 2.days.ago }
    end

    trait :accepted do
      accepted_at { Time.current }
    end
  end
end
