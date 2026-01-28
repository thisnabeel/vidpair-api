class Pairing < ApplicationRecord
  belongs_to :user

  enum :status, { waiting: 'waiting', matched: 'matched', cancelled: 'cancelled' }

  validates :status, presence: true

  scope :waiting_for_match, -> { where(status: 'waiting') }
end

