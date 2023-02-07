# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_02_07_074654) do

  create_table "auction_sites", force: :cascade do |t|
    t.string "website"
    t.string "site_name"
    t.string "site_url"
    t.string "short_description"
    t.text "full_description"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.boolean "shipping_available"
    t.string "ship_from"
    t.float "premium"
    t.datetime "last_scanned"
    t.string "site_type"
    t.string "category"
    t.string "unparsed_address"
    t.string "address"
    t.string "country"
    t.string "latitude"
    t.string "longitude"
    t.text "policies"
    t.string "auction_store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "auctions", force: :cascade do |t|
    t.string "main_site"
    t.string "auction_url"
    t.datetime "opening_date"
    t.datetime "closing_date"
    t.datetime "bidding_open"
    t.string "short_description"
    t.text "full_description"
    t.integer "lots"
    t.string "shipping_type"
    t.float "premium"
    t.integer "pallet_count"
    t.string "auction_store_id"
    t.integer "user_id"
    t.string "site"
    t.integer "ebay_value"
    t.integer "amz_value"
    t.integer "negg_value"
    t.float "shipping_cost"
    t.boolean "shipping_offered"
    t.integer "auction_site_id"
    t.boolean "ended"
    t.boolean "online_only"
    t.boolean "scanned"
    t.string "title"
    t.text "unparsed_address"
    t.string "latitude"
    t.string "longitude"
    t.float "distance"
    t.string "auctioneer_name"
    t.string "auction_url_code"
    t.string "event_name"
    t.string "auction_city"
    t.string "auction_zip"
    t.string "featured_picture_full"
    t.string "featured_picture_thumb"
    t.string "featured_picture_description"
    t.boolean "hide"
    t.string "bidding_notice"
    t.string "auction_notice"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_site_id"], name: "index_auctions_on_auction_site_id"
    t.index ["user_id"], name: "index_auctions_on_user_id"
  end

  create_table "bid_histories", force: :cascade do |t|
    t.integer "product_id"
    t.string "username"
    t.string "bid_count"
    t.string "bid_amount"
    t.string "bid_date_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_bid_histories_on_product_id"
  end

  create_table "comparable_products", force: :cascade do |t|
    t.integer "product_id"
    t.string "name"
    t.string "image_link"
    t.string "store_type"
    t.float "price"
    t.string "currency"
    t.string "store_link"
    t.float "shipping_weight"
    t.integer "qty_available"
    t.float "shipping_cost"
    t.string "shipping_unit"
    t.string "item_location"
    t.string "ships_to"
    t.string "returns"
    t.string "condition"
    t.string "category"
    t.string "sub_categories"
    t.float "ebay_fee_amount"
    t.float "ebay_fee_percantage"
    t.float "ebay_gross_revenue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_comparable_products_on_product_id"
  end

  create_table "errors", force: :cascade do |t|
    t.string "error"
    t.string "message"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "manifests", force: :cascade do |t|
    t.integer "lots"
    t.float "total_est_value"
    t.integer "auction_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_manifests_on_auction_id"
    t.index ["user_id"], name: "index_manifests_on_user_id"
  end

  create_table "page_htmls", force: :cascade do |t|
    t.string "page_url"
    t.text "html_code", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "page_items", force: :cascade do |t|
    t.string "r_name"
    t.string "p_link"
    t.string "website_link"
    t.string "location"
    t.string "latitude"
    t.string "longitude"
    t.string "contact"
    t.string "total_reviews"
    t.string "timing"
    t.string "cuisine"
    t.string "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "r_id"
    t.text "item_html_code", limit: 4294967295
    t.string "facebook_url"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.integer "quantity"
    t.text "description"
    t.string "upc_code"
    t.string "product_weight"
    t.string "dimensions"
    t.string "condition"
    t.string "brand_name"
    t.float "retail_price"
    t.integer "picture_count"
    t.string "packaging"
    t.string "manufacturer"
    t.string "product_model_name"
    t.string "ebay_search"
    t.string "amazon_search"
    t.string "file_name"
    t.string "storage_bin"
    t.integer "remaining_quantity"
    t.float "shipping_cost"
    t.boolean "shipping_offered"
    t.float "est_value"
    t.float "est_price"
    t.float "total_retail_purchased"
    t.float "total_retail_remaining"
    t.boolean "scanned"
    t.string "job_id"
    t.string "manifest_id"
    t.string "margin"
    t.boolean "active"
    t.text "sub_category"
    t.integer "bid_count"
    t.float "bid_max"
    t.float "buy_now"
    t.float "high_bid"
    t.float "min_bid"
    t.float "price_realized"
    t.integer "quantity_sold"
    t.string "time_left"
    t.string "product_url"
    t.string "item_id"
    t.boolean "has_comparables"
    t.float "ebay_profit_estimate"
    t.float "max_bid_price"
    t.float "min_bid_price"
    t.datetime "auction_closing_time"
    t.float "min_comp_price"
    t.float "max_comp_price"
    t.float "avg_comp_price"
    t.float "profit_potential_price"
    t.string "time_zone"
    t.string "event_item_id"
    t.string "sub_categories"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trip_advisor_htmls", force: :cascade do |t|
    t.string "page_url"
    t.text "page_html", limit: 4294967295
    t.integer "trip_advisor_main_page_html_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_advisor_main_page_html_id"], name: "index_trip_advisor_htmls_on_trip_advisor_main_page_html_id"
  end

  create_table "trip_advisor_items", force: :cascade do |t|
    t.string "item_page_url"
    t.text "item_page_html", limit: 4294967295
    t.integer "trip_advisor_html_id"
    t.string "r_id"
    t.string "r_name"
    t.string "location"
    t.string "latitude"
    t.string "longitude"
    t.string "contact"
    t.string "email"
    t.string "price"
    t.string "timing"
    t.string "cuisine"
    t.string "meals"
    t.string "special_diet"
    t.string "features"
    t.string "details"
    t.string "total_reviews"
    t.string "total_rating"
    t.string "website_link"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_advisor_html_id"], name: "index_trip_advisor_items_on_trip_advisor_html_id"
  end

  create_table "trip_advisor_main_page_htmls", force: :cascade do |t|
    t.string "page_url"
    t.text "page_html", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.string "country"
    t.string "latitude"
    t.string "longitude"
    t.string "unparsed_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vanilla_page_htmls", force: :cascade do |t|
    t.string "page_url"
    t.text "html_code", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vanilla_page_items", force: :cascade do |t|
    t.string "r_id"
    t.string "r_name"
    t.string "item_page_link"
    t.text "item_html_code", limit: 4294967295
    t.string "image"
    t.string "price"
    t.string "slogan"
    t.string "location"
    t.string "latitude"
    t.string "longitude"
    t.string "contact"
    t.string "timing"
    t.string "total_reviews"
    t.string "cuisine"
    t.string "details"
    t.string "facebook_link"
    t.string "website_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vanilla_page_html_id"
    t.index ["vanilla_page_html_id"], name: "index_vanilla_page_items_on_vanilla_page_html_id"
  end

end
