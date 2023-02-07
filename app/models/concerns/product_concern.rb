# frozen_string_literal: true

module ProductConcern # :nodoc:
  extend ActiveSupport::Concern
  included do
    def save_barcode_comparable_products(result, product, sch_type)
      content = JSON.parse(result.body)
      data = sch_type == "upc" ? content["Stores"] : content["Data"]
      return if data&.size&.zero?

      comparable_array = Array.new
      data.each do |pd|
        pd = sch_type == "upc" ? pd : pd["Stores"].first
        if pd["store_name"] == "Amazon US"
          item = { 
            store_type: pd["store_name"], 
            name: pd["title"],
            image_link: pd["image"], 
            store_link: pd["link"],
            price: pd["price"].to_f, 
            currency: pd["currency"],
            product_id: product.id 
          }
          comparable_array << item
        end
      end
      ComparableProduct.create(comparable_array)
    rescue StandardError => e
      puts "error in save_barcode_comparable_products" + e.message
    end

    def save_ebay_comparable_products(result, product)
      puts ".. Saving ebay search result data"
      data = result["findItemsByKeywordsResponse"].first["searchResult"]&.first
      
      return if data.values.first.to_i.zero?

      comparable_array = Array.new
      total_ebay_Items = data["item"].count
      data["item"].each_with_index do |pd, ebay_indx|
        puts "...Ebay item for product id #{product.id}}: #{ebay_indx+1}/#{total_ebay_Items}------"
        sell_info = pd["sellingStatus"]&.first["currentPrice"]&.first&.values
        ship_info = pd["shippingInfo"]&.first["shippingServiceCost"]&.first&.values

        # find item category
        category_name = ''
        begin
          if (pd["primaryCategory"] && pd["primaryCategory"][0] && pd["primaryCategory"][0]["categoryName"][0])
            category_name = pd["primaryCategory"][0]["categoryName"][0]
          end  
        rescue => e 
        end
        full_category = []
        begin
          doc = Nokogiri::HTML(URI.open(pd["viewItemURL"][0]))
          doc.css('nav ul li a span').each do |span_text|
            unless (span_text.children.text == "Email to friends" || span_text.children.text == "Share on Facebook - opens in a new window or tab" || span_text.children.text == "Share on Twitter - opens in a new window or tab" || span_text.children.text =="Share on Pinterest - opens in a new window or tab")
              full_category << span_text.children.text
            end
          end
        rescue => e
        end

        item = { 
          store_type: pd["globalId"]&.first, 
          name: pd["title"]&.first,
          image_link: pd["galleryURL"]&.first, 
          store_link: pd["viewItemURL"]&.first,
          price: sell_info&.second.to_f + ship_info&.second.to_f, 
          currency: sell_info&.first.to_s,
          condition: pd["condition"]&.first&.values&.flatten&.last.to_s,
          shipping_cost: ship_info&.second.to_f,
          product_id: product.id,
          category: category_name,
          sub_categories: full_category.present? ? full_category.join(", ") : nil
        }
        comparable_array << item
      end

     
      puts ".. comparable_array: #{comparable_array.count} #{comparable_array.present?}"
      puts ".. Product: #{product.id}-------------"

      if comparable_array.present?
        product.update_columns(has_comparables: true)
        ComparableProduct.create(comparable_array)
      end
    end

    def save_upcitemdb_comparable_products(result, product, sch_type)
      content = JSON.parse(result.body)
      return if content["total"].zero?
      begin
        comparable_array = Array.new
        content["items"].each do |c|
          c["offers"].each do |pd|
            next if pd["merchant"].blank?
            next if pd["domain"] != "amazon.com"
            ship_cost = pd["shipping"].to_s.gsub(/[^\d\.]/, "").to_f
            item = { store_type: pd["merchant"], name: pd["title"],
                    image_link: c["images"]&.first, store_link: pd["link"],
                    price: pd["price"].to_f + ship_cost, currency: pd["currency"],
                    shipping_cost: ship_cost, condition: pd["condition"],
                    product_id: product.id }
            comparable_array << item
          end
        end
        ComparableProduct.create(comparable_array)
      rescue StandardError => e
        puts "error in save_upcitemdb_compareable" + e.message
      end
    end
  end
end
