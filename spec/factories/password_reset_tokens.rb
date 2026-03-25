FactoryBot.define do
  factory :password_reset_token do
    association :user
    token_digest { Digest::SHA256.hexdigest(SecureRandom.urlsafe_base64(32)) }
    expires_at { 1.hour.from_now }
    used_at { nil }
  end
end
