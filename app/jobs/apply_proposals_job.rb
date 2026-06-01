class ApplyProposalsJob < ApplicationJob
  queue_as :default

  def perform
    proposals = Proposal.approved.where(action: "create")
    applied = 0
    errors = 0

    proposals.find_each do |proposal|
      ActiveRecord::Base.transaction do
        data = proposal.proposed_data
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

        proposal.update!(status: "applied")
        applied += 1
      end
    rescue => e
      errors += 1
      Rails.logger.error "[ApplyProposalsJob] Proposal ##{proposal.id} failed: #{e.message}"
    end

    Rails.logger.info "[ApplyProposalsJob] Applied: #{applied}, Errors: #{errors}"
  end

  private

  def resolve_category_ids(data)
    if data["new_category"] && data["new_parent_id"].present?
      parent = Category.find(data["new_parent_id"])
      child = Category.find_or_create_by!(code: data["new_child_name"], parent: parent)
      [child.id]
    elsif data["new_category"] && data["new_parent_name"].present?
      parent = Category.find_or_create_by!(code: data["new_parent_name"], parent: nil)
      child = Category.find_or_create_by!(code: data["new_child_name"], parent: parent)
      [child.id]
    else
      Array(data["category_ids"]).map(&:to_i)
    end
  end
end
