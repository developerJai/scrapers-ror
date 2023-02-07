class Product < ApplicationRecord
  has_many_attached :photos
  belongs_to :manifest
  has_many :comparable_products, dependent: :destroy
  has_many :bid_histories, dependent: :destroy
  validates :name, presence: true
  validates :category, presence: true
  include ProductsSearch
  include EbayProductsSearchScraper
  include BidConcern
  
  #after_save :save_comparable_product
  before_save :update_name
  
  scope :has_comparables, -> { where(has_comparables: true) }
  scope :active, -> { where(active: true) }
  scope :skip_real_estate, -> { where.not("lower(category) = ?", "real estate") }

  scope :search_by, -> (keyword, category) { 
    if category.present?
      where("lower(products.category)=? and lower(products.name) LIKE (?)", category, "%#{keyword}%")
    else
      where("lower(products.category) LIKE (?) or lower(products.name) LIKE (?)", "%#{keyword}%", "%#{keyword}%")
    end
  } 
  scope :with_status, -> (status_in) {
    case status_in
    when "past"
      joins(manifest: :auction).where("auctions.closing_date<?", Time.current)
    when "all"
      joins(manifest: :auction).where("auctions.id is not null")
    else
      # current
      joins(manifest: :auction).where("auctions.opening_date<=? and auctions.closing_date>=?", Time.current, Time.current)
    end
  }

  def update_name
    self.name = self.name.to_s
                      .gsub("HiBid.com", "")
                        .gsub("hibid","")
  end

  def updated_name
    self.name.to_s
      .gsub("HiBid.com", "")
        .gsub("hibid","")
  end

  def calc_est_price
    comp_products = comparable_products
    return if comp_products.size.zero?
    avg_price = comp_products.sum(:price) / comp_products.size
    update(est_price: avg_price, est_value: avg_price * quantity)
  end

  def get_prev(manifest)
    manifest.products.where("products.id < ? ", self.id).order("created_at asc").last
  end

  def get_next(manifest)
    manifest.products.where("products.id > ? ", self.id).order("created_at asc").first
  end

  def get_price_range
    comp_products = comparable_products
    return "" if comp_products.size.zero?

    "$" + comp_products.minimum("price").to_s + " to " + "$" + comp_products.maximum("price").to_s
  end

  def calculate_margin
    unless self.updated_bid.nil? || self.est_price.nil? 
    (self.updated_bid / self&.est_price) unless self.updated_bid.nil?
    end
  end

  def updated_bid
    current = update_bid
    if current
      current >= high_bid ? current : high_bid
    elsif high_bid
      high_bid
    else
      nil
    end
  end

  def update_bid
    get_updated_bid ||= self&.est_price
  end

  def get_price_vals
    comp_products = comparable_products
    return Array.new(4, "$0.00") if comp_products.size.zero?

    ["$" + comp_products.minimum("price").round(2).to_s,
     "$" + comp_products.maximum("price").round(2).to_s,
     "$" + (comp_products.sum(:price) / comp_products.size).round(2).to_s,
     "$" + median(comp_products.pluck(:price)).round(2).to_s]
  end

  def median(array)
    return 0 if array.nil?
    sorted = array.sort
    len = sorted.length
    (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
  end

  def self.check_progress(products)
    Delayed::Job.where(id: products.pluck(:job_id)).present?
  end

  def save_comparable_product
    job = self.delay.search_ebay_amazon_products(self)
    self.update(job_id: job.id)
  end
end
