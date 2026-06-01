class ApplicationController < ActionController::Base
  before_action :set_locale
  before_action :set_categories

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def set_locale
    I18n.locale = cookies[:locale]&.to_sym || I18n.default_locale
  end

  def set_categories
    @category_ids_with_markers = MarkerCategory.distinct.pluck(:category_id).to_set
    parent_ids = Category.where(id: @category_ids_with_markers).distinct.pluck(:parent_id).compact
    @parent_categories = Category.where(id: parent_ids).includes(:children)
    @all_parent_categories = Category.where(parent_id: nil).includes(:children)
  end
end
