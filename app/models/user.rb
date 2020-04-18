class User < ApplicationRecord
  include Clearance::User

  has_many :campaigns, dependent: :destroy
  has_many :maps, through: :campaigns

  validates :name, presence: true
end
