class UserIp < ApplicationRecord
  belongs_to :user

  def groups?
    for_checked.count { |group| group.is_a?(Array) }.positive?
  end

  def for_checked
    user_ips = user.ips.order(:created_at)

    grouped_ips = []
    current_group = []

    user_ips.each_with_index do |ip, index|
      if current_group.empty?
        current_group << ip
      elsif ip.created_at <= current_group.first.created_at + 1.hour
        current_group << ip
      else
        grouped_ips << (current_group.size > 1 ? current_group : current_group.first)
        current_group = [ip]
      end

      if index == user_ips.size - 1
        grouped_ips << (current_group.size > 1 ? current_group : current_group.first)
      end
    end

    grouped_ips
  end
end
