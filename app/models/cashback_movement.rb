class CashbackMovement < ApplicationRecord
  KINDS = %w[earned used reverted_earned reverted_used].freeze

  KIND_LABELS = {
    "earned"          => "Ganho",
    "used"            => "Usado",
    "reverted_earned" => "Estornado (ganho)",
    "reverted_used"   => "Estornado (uso)"
  }.freeze

  belongs_to :user
  belongs_to :payment, optional: true

  validates :amount_cents, presence: true, numericality: { other_than: 0 }
  validates :kind, presence: true, inclusion: { in: KINDS }

  scope :credits, -> { where(kind: %w[earned reverted_used]) }
  scope :debits, -> { where(kind: %w[used reverted_earned]) }

  
  def human_kind
    KIND_LABELS[kind]
  end
end