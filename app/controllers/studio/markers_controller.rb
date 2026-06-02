module Studio
  class MarkersController < BaseController
    PER_PAGE = 20

    def index
      @page = [params[:page].to_i, 1].max
      @markers = Marker.includes(:categories).order(created_at: :desc)
      @total = @markers.count
      @markers = @markers.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
      @total_pages = (@total.to_f / PER_PAGE).ceil
    end

    def edit
      @marker = Marker.find(params[:id])
    end

    def update
      @marker = Marker.find(params[:id])

      if @marker.update(marker_params)
        redirect_to studio_markers_path, notice: "Marker updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def marker_params
      params.require(:marker).permit(:photo)
    end
  end
end
