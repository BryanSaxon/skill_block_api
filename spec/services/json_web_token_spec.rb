require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode" do
    it "returns a JWT string" do
      token = described_class.encode(sub: 1)
      expect(token).to be_a(String)
      expect(token.split(".").length).to eq(3)
    end

    it "includes a jti claim" do
      token = described_class.encode(sub: 1)
      payload = described_class.decode(token)
      expect(payload[:jti]).to be_present
    end

    it "includes an expiration claim 24 hours from now" do
      token = described_class.encode(sub: 1)
      payload = described_class.decode(token)
      expect(Time.at(payload[:exp])).to be_within(5.seconds).of(24.hours.from_now)
    end
  end

  describe ".decode" do
    it "decodes a valid token and returns the payload" do
      token = described_class.encode(sub: 42)
      payload = described_class.decode(token)
      expect(payload[:sub]).to eq(42)
    end

    it "raises JWT::DecodeError for a tampered token" do
      token = described_class.encode(sub: 1)
      tampered = "#{token}garbage"
      expect { described_class.decode(tampered) }.to raise_error(JWT::DecodeError)
    end

    it "raises JWT::ExpiredSignature for an expired token" do
      token = described_class.encode(sub: 1)
      described_class.decode(token)
      allow(Time).to receive(:now).and_return(25.hours.from_now)
      expect { described_class.decode(token) }.to raise_error(JWT::ExpiredSignature)
    end
  end
end
