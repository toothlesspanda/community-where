class ModalTestController < PartiesController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  def index
  end

  def modal
    @modal_type = params[:modal_type]
  end

  def modal_different_layout
  end


  def modal_action
    @some_parameter = params[:some_parameter]
  end
end
