class AnalyseSubmissionsJob < ApplicationJob
  queue_as :default

  def perform
    analyser = SubmissionAnalyser.new

    unprocessed = MarkerSubmission
      .left_joins(:proposal)
      .where(proposals: { id: nil })
      .limit(SubmissionAnalyser::BATCH_SIZE)
      .to_a

    return if unprocessed.empty?

    analyser.analyse_batch(unprocessed)

    remaining = MarkerSubmission.left_joins(:proposal).where(proposals: { id: nil }).count
    if remaining > 0
      Rails.logger.info("[AnalyseSubmissionsJob] #{remaining} submissions remaining — scheduling next batch.")
      self.class.set(wait: 6.hours).perform_later
    end
  rescue LlmClient::ApiLimitError => e
    Rails.logger.warn("[AnalyseSubmissionsJob] #{e.message} — remaining submissions will be processed next run.")
  end
end
