class Campaign < ApplicationRecord
  has_many :characters, dependent: :destroy
  has_many :maps, dependent: :destroy
  belongs_to :current_map, class_name: "Map", optional: true
  belongs_to :user, optional: false

  validates :name, presence: true

  def populate_tokens
    maps.each(&:populate_tokens)
  end
end
