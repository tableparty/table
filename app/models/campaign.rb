class Campaign < ApplicationRecord
  has_many :maps, dependent: :destroy

  validates :name, presence: true
end
