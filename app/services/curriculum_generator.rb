# Generates a structured curriculum from document chunks via RAG + Claude API.
class CurriculumGenerator
  SYSTEM_PROMPT = <<~PROMPT
    You are a technical training curriculum designer for industrial manufacturing operations.
    You create structured training curricula for machine operators from technical documentation.

    Your output must be valid JSON matching this exact schema:
    {
      "title": "string — specific, descriptive curriculum title",
      "modules": [
        {
          "title": "string",
          "module_type": "content" | "quiz",
          "estimated_minutes": integer,
          "content": {
            // For content modules:
            "body": "markdown string with sections, callouts using > [!NOTE/CAUTION/WARNING/DANGER] syntax"
            // For quiz modules:
            "questions": [
              {
                "id": "q1",
                "text": "question text",
                "options": [
                  {"letter": "A", "text": "option text"},
                  {"letter": "B", "text": "option text"},
                  {"letter": "C", "text": "option text"},
                  {"letter": "D", "text": "option text"}
                ],
                "correct_answer": "A" | "B" | "C" | "D",
                "explanation": "1-3 sentences explaining why this answer is correct"
              }
            ]
          }
        }
      ]
    }

    Guidelines:
    - Alternate content modules with quiz modules (content → quiz → content → quiz pattern)
    - Each content module: 1-3 key concepts from the source material, 300-600 word body
    - Each quiz: 3-5 questions testing the preceding content module
    - Use > [!CAUTION] and > [!WARNING] for any safety-critical procedures
    - The escalate_if field in quiz explanations must be specific and quantified
    - Role levels: entry (fundamental concepts), experienced (procedures + troubleshooting), lead (advanced + training others)
    - Return ONLY the JSON object, no markdown fences, no preamble
  PROMPT

  def self.generate(curriculum:, document_ids:)
    # Retrieve relevant chunks via semantic search using curriculum title as query
    query_embedding = EmbeddingService.embed_batch([curriculum.title]).first
    chunks = retrieve_chunks(query_embedding, document_ids, limit: 20)

    context = chunks.map.with_index { |c, i| "--- Excerpt #{i + 1} ---\n#{c.content}" }.join("\n\n")

    machine_name = curriculum.organization_machine&.nickname ||
                   curriculum.organization_machine&.machine&.name ||
                   "the assigned machine"

    user_prompt = <<~PROMPT
      Generate a training curriculum for #{machine_name} operators at the #{curriculum.role_level} level.

      Source documentation excerpts:
      #{context}

      Requirements:
      - Machine context: #{machine_name}
      - Role level: #{curriculum.role_level}
      - Create 4-8 modules total (alternating content/quiz)
      - Ground every claim in the provided documentation
      - Include specific parameter values, thresholds, and procedures from the source material
    PROMPT

    client = Anthropic::Client.new(
      access_token: Rails.application.credentials.dig(:anthropic, :api_key) ||
                    ENV["ANTHROPIC_API_KEY"]
    )

    response = client.messages(
      model: "claude-opus-4-6",
      max_tokens: 8192,
      system: SYSTEM_PROMPT,
      messages: [{role: "user", content: user_prompt}]
    )

    raw = response.dig("content", 0, "text").to_s.strip
    JSON.parse(raw)
  rescue JSON::ParserError => e
    raise "Claude returned invalid JSON: #{e.message}"
  end

  def self.retrieve_chunks(query_embedding, document_ids, limit:)
    DocumentChunk
      .joins(:document)
      .where(documents: {id: document_ids})
      .nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .limit(limit)
  end
end
