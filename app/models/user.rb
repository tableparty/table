class User < ApplicationRecord
  include Clearance::User

  has_many :campaigns, dependent: :destroy

  validates :name, presence: true
end
