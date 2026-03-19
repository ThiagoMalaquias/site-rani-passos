class CampaignUserJob < ApplicationJob
  queue_as :low

  def perform(campaign_id, users_ids)
    campaign = Campaign.find(campaign_id)
    users = User.where(id: users_ids)

    campaign_users = users.map do |user|
      {
        campaign_id: campaign.id,
        name: user.name,
        email: user.email,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    CampaignUser.insert_all(campaign_users)
  end
end