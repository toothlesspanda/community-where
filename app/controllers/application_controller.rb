class ApplicationController < ActionController::Base
  before_action :set_categories

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def set_categories
    @parent_categories = Category.where(parent_id: nil).includes(:children)
  end
end
