class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    return unless document.processing?

    document.file.open do |file|
      result = PdfExtractor.process(file)
      document.update!(page_count: result[:pages])

      chunks = result[:chunks]
      return finish_error(document, "No text extracted from PDF") if chunks.empty?

      # Embed all chunks in batches
      embeddings = EmbeddingService.embed_batch(chunks)

      DocumentChunk.transaction do
        document.document_chunks.destroy_all
        chunks.each_with_index do |text, idx|
          document.document_chunks.create!(
            content: text,
            chunk_index: idx,
            embedding: embeddings[idx]
          )
        end
      end

      document.update!(status: :ready)
    end
  rescue => e
    Rails.logger.error("ProcessDocumentJob failed for #{document_id}: #{e.message}")
    Document.find_by(id: document_id)&.update(status: :error)
  end

  private

  def finish_error(document, msg)
    Rails.logger.warn("ProcessDocumentJob: #{msg} for document #{document.id}")
    document.update(status: :error)
  end
end
