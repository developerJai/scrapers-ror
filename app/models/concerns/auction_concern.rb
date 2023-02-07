module AuctionConcern # :nodoc:
  extend ActiveSupport::Concern
  include ProductsSearch
  included do
    def save_manifest_csv(url, auction)
      return unless url.present?

      file_path = "#{Rails.root}/tmp/auction_#{auction.id}.csv"
      File.delete(file_path) if File.file?(file_path)
      File.write(file_path, open(url).read.force_encoding("UTF-8"))
      if auction.manifests.blank?
        manifest_owner = current_user ||= User.first
        manifest = auction.manifests.create(quantity: auction.quantity, user_id: manifest_owner.id)
      else
        manifest = auction.manifests.first
      end
      data = CSV.parse(File.read(file_path), headers: true)
      save_product_data(data, manifest, file_path)
      # I would keep these in case you need to reprocess
      File.delete(file_path) if File.file?(file_path)
    end

    def save_product_csv(data, manifest, file_path)
      # Reset with new manifest if you're reprocessing?
      # What happens when this is auction lots not items
      #manifest.products.delete_all
      rows = data.by_row
      # wont save data if it has no model , no manufacturer, no upc code
      return if rows.size == 1 && (rows[0]["Manufacturer"].blank? && rows[0]["Model"].blank? && rows[0]["UPC"].blank?)

      data.each_with_index do |row, k|
        # Ok, this adds a new product each time it encounters a row, even if the same product exists
        # Maybe its possible to determine if the manufacturer + model name + upc match, it's the same
        # or if the upc code matches its the same
        puts "#{k} :: #{row}"
        product = Product.new
        product.manifest_id = manifest.id
        product.name = retreive_model_name(row)
        product.category = row["Category"].to_s
        product.description = row["Item Description"].to_s
        product.quantity = row["Qty"].to_i
        product.retail_price = row["Retail Per Unit"].to_f
        product.total_retail_purchased = row["Total Retail"].to_f
        product.condition = row["Condition"].to_s
        product.packaging = row["Packaging"].to_s
        product.upc_code = row["UPC"].to_s
        product.manufacturer = row["Manufacturer"].to_s
        product.product_model_name = row["Model"].to_s
        product.save!
        product.reload
      end
    end

    def retreive_model_name(data)
      if data["Manufacturer"].blank? && data["Model"].blank?
        if data["Item Description"].present?
          data["Item Description"].to_s
        else
          "General Goods"
        end
      else
        data["Manufacturer"].to_s + " " + data["Model"].to_s
      end
    end

    def compare_ebay_amazon_products(product)
      return if product.comparable_products.present?

      search_ebay_amazon_products(product)
    end
  end
end