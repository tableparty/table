class Map < ApplicationRecord
  ZOOM_LEVELS = [0.25, 0.5, 1, 1.5, 2].freeze

  belongs_to :campaign
  has_many :tokens, dependent: :destroy

  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true
  validates_inclusion_of :zoom, in: ->(map) { (0..map.zoom_max) }

  before_update :scale_coordinates

  def zoom_max
    ZOOM_LEVELS.length - 1
  end

  def original_height
    image.metadata[:height]
  end

  def original_width
    image.metadata[:width]
  end

  def height
    (original_height * zoom_amount).round
  end

  def width
    (original_width * zoom_amount).round
  end

  def center_image
    maybe_analyze_image
    update(x: (width / 2).round, y: (height / 2).round)
  end

  def zoom_amount
    ZOOM_LEVELS[zoom]
  end

  private

  def scale_coordinates
    maybe_analyze_image
    if zoom_changed?
      zoom_factor = zoom_amount / ZOOM_LEVELS[zoom_was]
      self.x = x * zoom_factor
      self.y = y * zoom_factor
    end
  end

  def maybe_analyze_image
    if original_width.blank? || original_height.blank?
      image.analyze
    end
  end
end
