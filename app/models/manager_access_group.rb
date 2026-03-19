class ManagerAccessGroup < ApplicationRecord
  belongs_to :manager
  belongs_to :access_group
end
