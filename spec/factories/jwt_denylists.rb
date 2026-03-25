FactoryBot.define do
  factory :jwt_denylist do
    jti { SecureRandom.uuid }
    exp { 24.hours.from_now }
  end
end
