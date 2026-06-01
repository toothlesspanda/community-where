module Studio
  class SubmissionsController < BaseController
    PER_PAGE = 20

    def index
      @page = [params[:page].to_i, 1].max
      @submissions = MarkerSubmission
        .includes(:proposal)
        .order(created_at: :desc)
      @total = @submissions.count
      @submissions = @submissions.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
      @total_pages = (@total.to_f / PER_PAGE).ceil
    end

    def show
      @submission = MarkerSubmission.find(params[:id])
    end
  end
end
