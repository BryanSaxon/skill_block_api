# Extracts plain text from a PDF file by page, returns array of page strings.
class PdfExtractor
  CHUNK_WORDS = 400
  CHUNK_OVERLAP = 50

  # Returns { pages: Integer, chunks: Array<String> }
  def self.process(io)
    reader = PDF::Reader.new(io)
    pages = reader.pages.count

    # Concatenate all text, track page count
    full_text = reader.pages.map(&:text).join("\n\n")
    chunks = chunk_text(full_text)

    {pages: pages, chunks: chunks}
  end

  # Split text into overlapping word-window chunks for embedding.
  def self.chunk_text(text)
    words = text.split
    return [text.strip] if words.length <= CHUNK_WORDS

    chunks = []
    start = 0
    while start < words.length
      slice = words[start, CHUNK_WORDS]
      chunks << slice.join(" ")
      break if start + CHUNK_WORDS >= words.length
      start += CHUNK_WORDS - CHUNK_OVERLAP
    end
    chunks
  end
end
