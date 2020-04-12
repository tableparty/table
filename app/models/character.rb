class Character < ApplicationRecord
  belongs_to :campaign
  has_one_attached :image
  has_many :tokens, as: :tokenable, dependent: :destroy, inverse_of: :tokenable

  validates :campaign, presence: true
  validates :image, presence: true
  validates :name, presence: true
end
