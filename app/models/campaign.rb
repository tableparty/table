class Campaign < ApplicationRecord
  validates :name, presence: true
end
