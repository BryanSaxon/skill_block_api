class JsonWebToken
  EXPIRATION = 24.hours
  ALGORITHM = "HS256"

  def self.encode(payload)
    payload[:jti] = SecureRandom.uuid
    payload[:iat] = Time.current.to_i
    payload[:exp] = EXPIRATION.from_now.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, {algorithm: ALGORITHM})[0]
    HashWithIndifferentAccess.new(decoded)
  end

  def self.secret_key
    Rails.application.secret_key_base
  end
  private_class_method :secret_key
end
