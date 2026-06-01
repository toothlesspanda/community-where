module Studio
  class DashboardController < BaseController
    def index
      @unprocessed_count = MarkerSubmission.left_joins(:proposal).where(proposals: { id: nil }).count
      @approved_count = Proposal.approved.count
    end

    def run_analysis
      AnalyseSubmissionsJob.perform_later
      redirect_to studio_root_path, notice: "Analysis job queued."
    end

    def apply_proposals
      ApplyProposalsJob.perform_later
      redirect_to studio_root_path, notice: "Apply proposals job queued."
    end
  end
end
