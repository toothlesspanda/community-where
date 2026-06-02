module Studio
  class ProposalsController < BaseController
    before_action :set_proposal, only: %i[show update approve reject execute]

    def index
      @status = params[:status].presence || "pending"
      @proposals = Proposal.where(status: @status)
                           .includes(:marker_submission)
                           .order(created_at: :desc)
      @counts = Proposal.group(:status).count
    end

    def show
      @parent_categories = Category.where(parent_id: nil).includes(:children)
    end

    def update
      if @proposal.update(proposal_params)
        redirect_to studio_proposal_path(@proposal), notice: "Proposal updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def approve
      @proposal.update!(status: "approved")
      redirect_to studio_proposals_path, notice: "Proposal approved."
    end

    def reject
      @proposal.update!(status: "rejected")
      redirect_to studio_proposals_path, notice: "Proposal rejected."
    end

    def execute
      return redirect_to studio_proposals_path, alert: "Not approved." unless @proposal.status == "approved"

      data = @proposal.proposed_data

      ActiveRecord::Base.transaction do
        category_ids = resolve_category_ids(data)

        marker = Marker.create!(
          name: data["name"],
          description: data["description"],
          latitude: data["latitude"],
          longitude: data["longitude"],
          address: data["address"],
          coordinates: "POINT(#{data['longitude']} #{data['latitude']})",
          name_translations: data["name_translations"] || {},
          description_translations: data["description_translations"] || {}
        )

        category_ids.each { |id| marker.categories << Category.find(id) }

        submission = @proposal.marker_submission
        if submission.photo.attached?
          marker.photo.attach(submission.photo.blob)
        end

        @proposal.update!(status: "applied")
      end

      redirect_to studio_proposals_path, notice: "Marker created from proposal."
    end

    private

    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    def proposal_params
      params.require(:proposal).permit(:reviewer_notes, proposed_data: {})
    end

    def resolve_category_ids(data)
      child_name = data["new_child_name"] || data["suggested_category"]

      if data["new_category"] && child_name.blank?
        return Array(data["category_ids"]).map(&:to_i)
      end

      if data["new_category"] && data["new_parent_id"].present?
        parent = Category.find(data["new_parent_id"])
        child = Category.find_or_create_by!(code: child_name, parent: parent)
        [child.id]
      elsif data["new_category"] && data["new_parent_name"].present?
        parent = Category.find_or_create_by!(code: data["new_parent_name"], parent: nil)
        child = Category.find_or_create_by!(code: child_name, parent: parent)
        [child.id]
      else
        Array(data["category_ids"]).map(&:to_i)
      end
    end
  end
end
