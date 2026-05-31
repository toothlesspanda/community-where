class MarkerSubmissionsController < ApplicationController
  def create
    @marker_submission = MarkerSubmission.new(marker_submission_params)

    unless verify_recaptcha(model: @marker_submission)
      flash.now[:alert] = "Verificação falhou. Tenta novamente."
      render turbo_stream: turbo_stream.replace(
        "new-marker-modal",
        partial: "marker_submissions/new_marker_form",
        locals: { marker_subsmission: @marker_submission }
      )
      return
    end

    if @marker_submission.save
      flash.now[:notice] = "Marcador submetido para avaliação!"

      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace("new-marker-modal", partial: "marker_submissions/new_marker_form", locals: { marker_subsmission: MarkerSubmission.new })
      ]
    else
      render turbo_stream: turbo_stream.replace(
        "new-marker-modal",
        partial: "marker_submissions/new_marker_form",
        locals: { marker_subsmission: @marker_submission }
      )
    end
  end

  private

  def marker_submission_params
    permitted = params.require(:marker_submission).permit(
      :latitude,
      :longitude,
      :description,
      :name,
      :name_en,
      :description_en,
      :address,
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