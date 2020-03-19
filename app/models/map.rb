class Map < ApplicationRecord
  belongs_to :campaign

  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true
end
