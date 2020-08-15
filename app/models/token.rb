class Token < ApplicationRecord
  SIZES = {
    "tiny" => 0.5,
    "small" => 1,
    "medium" => 1,
    "large" => 2,
    "huge" => 3,
    "gargantuan" => 4
  }.freeze
  belongs_to :map
  belongs_to :token_template, optional: true
  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true
  validates_inclusion_of :size, in: SIZES.keys, allow_blank: true

  after_create_commit :broadcast_token_creation

  def self.size_names
    SIZES.keys
  end

  def name
    read_attribute(:name).presence || token_template.try(:name)
  end

  def size
    read_attribute(:size).presence || token_template.try(:size)
  end

  token_image = instance_method(:image)
  define_method(:image) do
    token_image.bind(self).().presence || token_template.try(:image)
  end

  def copy_on_place?
    identifier.blank? && token_template&.copy_on_place?
  end

  def size_scale
    SIZES[size]
  end

  private

  def broadcast_token_creation
    TokenCreationBroadcastJob.perform_later(self)
  end
end
