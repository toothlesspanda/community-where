class SubmissionAnalyser
  # Groq free tier: 12K TPM (input+output), 100K TPD, 30 RPM, 1K RPD
  SYSTEM_PROMPT_TOKENS = 800
  TOKENS_PER_SUBMISSION = 450 # ~200 input + ~250 output
  TOKENS_PER_MINUTE = 12_000
  BATCH_SIZE = ((TOKENS_PER_MINUTE - SYSTEM_PROMPT_TOKENS) / TOKENS_PER_SUBMISSION).clamp(1, 20)

  def initialize(client: LlmClient.new)
    @client = client
    @categories = load_categories
  end

  def analyse_batch(submissions)
    return if submissions.empty?

    duplicates, to_analyse = partition_duplicates(submissions)

    # Duplicates: create skip proposals without calling the LLM
    duplicates.each do |submission|
      Proposal.create!(
        marker_submission: submission,
        action: "skip",
        confidence: 1.0,
        proposed_data: {
          name: submission.name,
          description: submission.description,
          latitude: submission.latitude.to_f,
          longitude: submission.longitude.to_f,
          address: submission.address,
          reason: "Duplicate — marker with same name and category already exists."
        }
      )
    end

    return if to_analyse.empty?

    messages = [
      { role: "system", content: system_prompt },
      { role: "user", content: batch_prompt(to_analyse) }
    ]

    max_output = to_analyse.size * 250
    raw = @client.chat(messages, max_tokens: max_output)
    results = JSON.parse(raw)
    results = [results] if results.is_a?(Hash)

    ActiveRecord::Base.transaction do
      to_analyse.each_with_index do |submission, i|
        result = results[i]
        next unless result

        Proposal.create!(
          marker_submission: submission,
          action: result["action"] || "create",
          confidence: result["confidence"]&.to_f,
          proposed_data: build_proposed_data(result, submission)
        )
      end
    end
  end

  private

  def partition_duplicates(submissions)
    existing = Marker.joins(:categories).pluck("LOWER(markers.name)", "categories.id")
    existing_set = existing.to_set

    submissions.partition do |s|
      s.category_id && existing_set.include?([s.name&.downcase, s.category_id])
    end
  end

  def build_proposed_data(result, submission)
    data = {
      name: result["name"] || submission.name,
      description: result["description"] || submission.description,
      latitude: (result["latitude"] || submission.latitude).to_f,
      longitude: (result["longitude"] || submission.longitude).to_f,
      address: result["address"] || submission.address,
      name_translations: { "en" => result["name_en"] },
      description_translations: { "en" => result["description_en"] },
      reason: result["reason"]
    }

    if result["new_category"]
      data[:new_category] = true
      data[:suggested_category] = result["suggested_category"]
    else
      data[:category_ids] = Array(result["category_ids"]).map(&:to_i)
    end

    data
  end

  def load_categories
    Category.where(parent_id: nil).includes(:children).map do |parent|
      children = parent.children.map { |c| { id: c.id, code: c.code } }
      { name: parent.code, color: parent.hex_color, children: children }
    end
  end

  def system_prompt
    <<~PROMPT
      You are a data curator for Community Where, a platform that maps collection points and community resources in Portugal (recycling, donations, electric charging, etc.).

      Your job is to analyse user-submitted markers and produce curated versions. For each submission you must:

      1. **Validate** — Check if the submission looks legitimate (real name, coherent description, valid coordinates in Portugal).
      2. **Normalize** — Clean up the name and description (fix typos, capitalize properly, remove unnecessary text).
      3. **Categorize** — Assign the most appropriate category_ids from the available categories if they exist. If no matching category exists, set category_ids to null and add "new_category": true with "suggested_category": "name of suggested category".
      4. **Translate** — Provide English translations for name and description.

      Available categories:
      #{@categories.to_json}

      Respond with a JSON **array** — one object per submission, in the same order. Each object must have:
      - submission_id: the ID from the input
      - action: "create" or "skip"
      - confidence: 0.0 to 1.0
      - name: curated name in Portuguese
      - description: curated description in Portuguese
      - name_en: English translation of the name
      - description_en: English translation of the description
      - latitude: validated latitude
      - longitude: validated longitude
      - address: cleaned address
      - category_ids: array of category IDs (from the children, not parents) or null
      - new_category: true if no matching category exists, omit otherwise
      - suggested_category: suggested category name if new_category is true
      - reason: brief explanation of your decision

      Respond ONLY with the JSON array, no other text.
    PROMPT
  end

  def batch_prompt(submissions)
    items = submissions.map do |s|
      data = {
        submission_id: s.id,
        name: s.name,
        description: s.description,
        latitude: s.latitude.to_f,
        longitude: s.longitude.to_f,
        address: s.address,
        name_en: s.name_en,
        description_en: s.description_en
      }

      if s.category
        data[:category] = s.category.code
      else
        data[:new_parent_category] = s.new_parent_name
        data[:new_child_category] = s.new_child_name
      end

      data
    end

    <<~PROMPT
      Submissions to analyse:
      #{items.to_json}
    PROMPT
  end
end
