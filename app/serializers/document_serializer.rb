class DocumentSerializer
  include JSONAPI::Serializer

  attributes :name, :document_type, :status, :page_count, :created_at

  belongs_to :organization
  belongs_to :organization_machine
end
