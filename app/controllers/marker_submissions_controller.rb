class MarkerSubmissionsController < ApplicationController
  def create
    @marker_submission = MarkerSubmission.new(marker_submission_params)
    Rails.logger.info "[MarkerSubmission] Params: #{marker_submission_params.to_h}"

    unless verify_recaptcha(model: @marker_submission)
      flash.now[:alert] = t("marker_submissions.recaptcha_failed")
      render turbo_stream: turbo_stream.replace(
        "new-marker-form",
        partial: "marker_submissions/new_marker_form",
        locals: { marker_submission: @marker_submission }
      )
      return
    end

    if @marker_submission.save
      Rails.logger.info "[MarkerSubmission] Created ##{@marker_submission.id}"
      flash.now[:notice] = t("marker_submissions.success")

      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace("new-marker-form", partial: "marker_submissions/new_marker_form", locals: { marker_submission: MarkerSubmission.new })
      ]
    else
      Rails.logger.warn "[MarkerSubmission] Errors: #{@marker_submission.errors.full_messages}"
      render turbo_stream: turbo_stream.replace(
        "new-marker-form",
        partial: "marker_submissions/new_marker_form",
        locals: { marker_submission: @marker_submission }
      )
    end
  end

  private

  def marker_submission_params
    params.require(:marker_submission).permit(
      :latitude,
      :longitude,
      :description,
      :name,
      :name_en,
      :description_en,
      :address,
      category_ids: []
    )
  end
end