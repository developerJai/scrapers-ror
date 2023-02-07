class Auction < ApplicationRecord
  include AuctionConcern

  belongs_to :user
  belongs_to :auction_site, optional: true

  has_one :manifest, dependent: :destroy
  has_many :products, through: :manifest

  has_many_attached :photos

  validates :featured_picture_full, url: true, allow_blank: true 
  validates :featured_picture_thumb, url: true, allow_blank: true 

  acts_as_mappable :default_units => :miles,
                  :default_formula => :sphere,
                  :distance_field_name => :distance,
                  :lat_column_name => :latitude,
                  :lng_column_name => :longitude

  validates :auction_url, url: true, presence: true

  scope :active, -> { where(ended: false) }
  scope :search_by, -> (keyword, category) { 
    if category.present?
      left_outer_joins(:products).where("(closing_date is not null and lower(products.category)=? and (lower(auctions.title) LIKE (?) or lower(auctions.unparsed_address) LIKE (?) or lower(auctions.auctioneer_name) LIKE (?)))", category, "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
    else
      left_outer_joins(:products).where("(closing_date is not null and (lower(auctions.title) LIKE (?) or lower(auctions.unparsed_address) LIKE (?) or lower(auctions.auctioneer_name) LIKE (?)))", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%")
    end
  } 

  scope :near_by, -> (coords) {
    if coords.present?
      within(500, :origin => coords)
    else
      where("auctions.id is not null")
    end
  }

  scope :with_status, -> (status_in) {
    case status_in
    when "past"
      where("auctions.closing_date<?", Time.current)
    when "all"
      where("auctions.id is not null")
    else
      # current
      where("auctions.opening_date<=? and auctions.closing_date>=?", Time.current, Time.current)
    end
  }

  before_save :update_title

  def check_comparabale_products
    # product_ids = manifests.first.products.pluck(:id)
    product_ids = manifest.products.pluck(:id)
    return ComparableProduct.where(product_id: product_ids).present?
  end

  def calc_whole_manifest
    # return if manifests.blank?
    # manifest = manifests.first
    total_price = manifest&.products&.sum(:est_value).to_f.round(2)
    manifest.update(total_est_value: total_price) if manifest
  end

  def update_current_bid
    begin
      page = Nokogiri::HTML(open(self.auction_url))
      update(current_bid: page.search('span#current_bid_amount').text.gsub(/[^\d\.]/, '').strip)
    rescue StandardError => e
      puts e
    end
  end

  def self.skip_duplicate_records
    ids = self.select("MIN(id) as id").group(:title,:full_description).collect(&:id)
    where(id: ids).or(self.where(full_description: nil)).or(self.where(title: nil))
  end

  def auction_site_url
    if self.auction_site_id.present?
      auction_site = AuctionSite.find_by_id(self.auction_site_id)
      site_url = auction_site ? auction_site.site_url : "#"
    else
      site_url = "#"
    end
  end

  def update_title
    self.title = self.title.to_s
                      .gsub("| Live and Online Auctions on HiBid.com","")
                        .gsub("Live and Online Auctions on HiBid.com","")
                          .gsub("HiBid.com", "")
                            .gsub("HiBid", "")
  end

  def updated_title
    self.title.to_s
          .gsub("| Live and Online Auctions on HiBid.com","")
            .gsub("Live and Online Auctions on HiBid.com","")
              .gsub("HiBid.com", "")
                .gsub("HiBid", "")
  end
end
