class TokenTemplate < ApplicationRecord
  belongs_to :campaign
  has_one_attached :image
  has_many :tokens, dependent: :destroy

  validates :campaign, presence: true
  validates :image, presence: true
  validates :name, presence: true
  validates_inclusion_of :size, in: Token.size_names
end
