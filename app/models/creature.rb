class Creature < ApplicationRecord
  belongs_to :campaign
  has_one_attached :image
  has_many :tokens, as: :tokenable, dependent: :destroy, inverse_of: :tokenable

  validates :campaign, presence: true
  validates :image, presence: true
  validates :name, presence: true
  validates_inclusion_of :size, in: Token.size_names

  def copy_on_place?
    true
  end
end
