class Campaign < ApplicationRecord
  has_many :maps, dependent: :destroy
  belongs_to :current_map, class_name: "Map", optional: true

  validates :name, presence: true
end
