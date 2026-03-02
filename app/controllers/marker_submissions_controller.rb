class MarkerSubmissionsController < ApplicationController
  def create
    @marker_submission = MarkerSubmission.new(marker_submission_params)

    if @marker_submission.save
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Marcador submetido para validação." }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: @marker_submission.errors.full_messages.to_sentence }
        format.turbo_stream
      end
    end
  end

  private

  def marker_submission_params
    permitted = params.require(:marker_submission).permit(
      :latitude,
      :longitude,
      :description,
      :name,
      :parent_category_id,
      :category_id,
      :new_parent_name,
      :new_child_name
    )

    permitted[:category_id] = nil if permitted[:category_id].to_i == 0
    permitted[:parent_category_id] = nil if permitted[:parent_category_id].to_i == 0

    permitted
  end
end