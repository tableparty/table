class Token < ApplicationRecord
  belongs_to :map
  belongs_to :tokenable, polymorphic: true, optional: true
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true

  def name
    read_attribute(:name).presence || tokenable.try(:name)
  end

  token_image = instance_method(:image)
  define_method(:image) do
    token_image.bind(self).().presence || tokenable.try(:image)
  end
end
