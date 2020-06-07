class Map < ApplicationRecord
  ZOOM_LEVELS = [0.25, 0.5, 1, 1.5, 2].freeze
  NORMALIZED_GRID_SIZE = 50

  belongs_to :campaign
  has_many :tokens, dependent: :destroy
  has_many :fog_areas, dependent: :destroy

  has_one_attached :image

  validates :name, presence: true
  validates :image, presence: true
  validates :grid_size, presence: true, numericality: true
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

  def scaled_height
    original_height * NORMALIZED_GRID_SIZE / grid_size
  end

  def scaled_width
    original_width * NORMALIZED_GRID_SIZE / grid_size
  end

  def height
    (scaled_height * zoom_amount).round
  end

  def width
    (scaled_width * zoom_amount).round
  end

  def center_image
    maybe_analyze_image
    update(x: (width / 2).round, y: (height / 2).round)
  end

  def zoom_amount
    ZOOM_LEVELS[zoom]
  end

  def populate_characters
    campaign.characters.each do |character|
      tokens.find_or_create_by(token_template: character)
    end
  end

  def copy_token(token)
    tokens.create(
      token_template: token.token_template,
      identifier: generate_identifier(token),
      x: token.x,
      y: token.y,
      stashed: false
    )
  end

  private

  def generate_identifier(token)
    if token.token_template
      tokens.where(token_template: token.token_template).size
    elsif token.name.present?
      tokens.where(name: token.name).size
    end
  end

  def scale_coordinates
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
