class FogArea < ApplicationRecord
  BASIC_SVG_PATH = /M (?:-?\d+ ){2}(?:L (?:-?\d+ ){2})*Z/.freeze

  belongs_to :map

  validates :map, presence: true
  validates :path, presence: true, format: { with: BASIC_SVG_PATH }
end
