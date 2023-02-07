class AuctionSite < ApplicationRecord
  acts_as_mappable :default_units => :miles,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  geocoded_by :unparsed_address

  scope :search_by, -> (keyword) {
                    where("lower(site_name) LIKE (?) or lower(unparsed_address) LIKE (?) or lower(website) LIKE (?)", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") 
                  }

  def self.hibid
    return 2
  end
end
