class Manifest < ApplicationRecord
  belongs_to :auction
  belongs_to :user

  has_many :products, dependent: :destroy
end
