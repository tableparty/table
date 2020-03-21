class Token < ApplicationRecord
  belongs_to :map
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true
end
