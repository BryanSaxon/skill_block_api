class DocumentsController < ApplicationController
  before_action :set_organization
  before_action :set_document, only: %i[show destroy]

  def index
    authorize Document
    docs = policy_scope(Document)
      .where(organization: @organization)
      .includes(:organization_machine)
      .order(created_at: :desc)

    docs = docs.where(status: params[:status]) if params[:status].present?

    render json: DocumentSerializer.new(docs, include: [:organization_machine]).serializable_hash
  end

  def show
    authorize @document
    render json: DocumentSerializer.new(@document).serializable_hash
  end

  def create
    authorize Document

    doc = Document.new(
      organization: @organization,
      organization_machine_id: params[:organization_machine_id],
      name: params[:name],
      document_type: params[:document_type],
      status: :processing
    )

    if params[:file].present?
      doc.file.attach(params[:file])
    end

    if doc.save
      ProcessDocumentJob.perform_later(doc.id)
      render json: DocumentSerializer.new(doc).serializable_hash, status: :created
    else
      render json: {errors: doc.errors.full_messages}, status: :unprocessable_content
    end
  end

  def destroy
    authorize @document
    @document.destroy
    head :no_content
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_document
    @document = @organization.documents.find(params[:id])
  end
end
