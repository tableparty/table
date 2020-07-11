class FogArea < ApplicationRecord
  belongs_to :map

  validates :map, presence: true
  validates :path, presence: true
end
