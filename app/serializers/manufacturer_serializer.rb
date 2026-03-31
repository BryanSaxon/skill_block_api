class ManufacturerSerializer
  include JSONAPI::Serializer

  attributes :name

  has_many :machines
end
