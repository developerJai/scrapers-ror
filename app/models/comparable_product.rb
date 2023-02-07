class ComparableProduct < ApplicationRecord
  belongs_to :product
  has_many_attached :photos
end
