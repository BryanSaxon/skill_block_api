module ResponseHelpers
  def json
    JSON.parse(response.body, symbolize_names: true)
  end
end

RSpec.configure do |config|
  config.include ResponseHelpers, type: :request
end
