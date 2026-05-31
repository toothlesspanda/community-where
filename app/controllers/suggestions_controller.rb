class SuggestionsController < ApplicationController
  def create
    @suggestion = Suggestion.new(suggestion_params)

    unless verify_recaptcha(model: @suggestion)
      flash.now[:alert] = "Verificação falhou. Tenta novamente."
      render turbo_stream: turbo_stream.replace(
        "suggestion-modal",
        partial: "suggestions/form",
        locals: { suggestion: @suggestion }
      )
      return
    end

    if @suggestion.save
      flash.now[:notice] = I18n.t("suggestions.success")

      render turbo_stream: [
        turbo_stream.update("flash", partial: "shared/flash"),
        turbo_stream.replace("suggestion-modal", partial: "suggestions/form", locals: { suggestion: Suggestion.new })
      ]
    else
      render turbo_stream: turbo_stream.replace(
        "suggestion-modal",
        partial: "suggestions/form",
        locals: { suggestion: @suggestion }
      )
    end
  end

  private

  def suggestion_params
    params.require(:suggestion).permit(:body)
  end
end
