module Studio
  class SuggestionsController < BaseController
    PER_PAGE = 20

    def index
      @page = [params[:page].to_i, 1].max
      @suggestions = Suggestion.order(created_at: :desc)
      @total = @suggestions.count
      @suggestions = @suggestions.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
      @total_pages = (@total.to_f / PER_PAGE).ceil
    end
  end
end
