class Token < ApplicationRecord
  belongs_to :map
  belongs_to :tokenable, polymorphic: true, optional: true
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true

  after_create_commit :broadcast_token_creation

  def name
    read_attribute(:name).presence || tokenable.try(:name)
  end

  token_image = instance_method(:image)
  define_method(:image) do
    token_image.bind(self).().presence || tokenable.try(:image)
  end

  def copy_on_place?
    identifier.blank? && tokenable&.copy_on_place?
  end

  private

  def broadcast_token_creation
    TokenBroadcastJob.perform_later(self)
  end
end
