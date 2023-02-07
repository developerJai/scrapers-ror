class EbayScrapersController < ApplicationController
  before_action :find_product, only: [:create]

  def create
    @retry_count = 0
    # ebay_scraper(product.name, product.manifest.auction.auction_zip)

    products = ebay_scraper(@product.name)
    if products.count>0
      products.each_with_index do |item,ind|
        data = { 
          store_type: item[:ebay_id], 
          name: item[:title],
          image_link: item[:image_link], 
          store_link: item[:ebay_product_link],
          price: item[:price].to_f, 
          currency: item[:currency],
          condition: item[:sub_title],
          shipping_cost: item[:shipping_cost].to_f,
          product_id: @product.id,
          category: item[:categories].first,
          sub_categories: item[:categories].join(", ")
        }
        comp = ComparableProduct.where(product_id: @product.id, store_link: item[:ebay_product_link]).first
        if comp 
          comp.update(data)
        else
          ComparableProduct.create(data)
        end
      end
    end

    render json: { code: 200, message: "Data scraped successfully" }
  end

  def ebay_refine_data
    filename = Rails.root.join("lib/data/ebay/categories", "categories.json")
    jsonfile = File.read(filename)
    data = JSON.parse(jsonfile)
    prices_data = data["prices"]
    categories = []
    prices_data.each do |cat_data|
      cat_data["categories"].each do |cat|
        categories << cat["title"]
      end
    end

    default_category_data = get_category_price_data(prices_data, "all_others")
    default_category_prices = default_category_data[:data]

    Product.active.each_with_index do |product, index|
      Rails.logger.info "======== Product Index #{index}"
      Rails.logger.info "======== Product Category: #{product.category}"
      # Find product category from all ebay categories prices table
      category_title = nil
      categories.each do |cat|
        category_title = cat.to_s if product.category.to_s.strip.include? cat.to_s
        break;
      end

      total_comp_products = product.comparable_products.count-1
      Rails.logger.info "Total comparable products #{total_comp_products+1}"
      product.comparable_products.each_with_index do |comparable_product,cind|
        Rails.logger.info "------ Comparing product: #{cind}/#{total_comp_products}"
        total_price = comparable_product.price.to_f + comparable_product.try(:shipping_cost)
        
        if category_title.present?
          Rails.logger.info "Product category found in ebay prices table json: #{category_title}"
          # If category_title present means product category_title matching with the category in the table
          # now check sub_categories are matching or not
          category_data = get_category_price_data(prices_data, category_title)
          if category_data
            Rails.logger.info "Product category's pricing data found in json"
            category_prices = category_data[:data]
            cat_json = category_data[:category_info]

            is_category_matched = true
            subcats = cat_json["subcats"]
            if subcats.present?
              # If subcats present means subcats must match to apply prices
              Rails.logger.info "Matching product subcategories..."
              total_subcats = cat_json["subcats"].count
              Rails.logger.info "Total subcategories: #{total_subcats}"
              cat_json["subcats"].each_with_index do |subcat, indx|
                if product.sub_categories.to_s.include?(subcat)
                  # subcategory is matching with product's subcategory
                  # stop here now
                  is_category_matched = true
                  Rails.logger.info "Product Subcategory matched at index #{indx}/#{total_subcats}!!"
                  break;
                else
                  # subcategory is not matching check for next
                  "Subcat not matched at index #{indx}/#{total_subcats}"
                  is_category_matched = false
                end
              end
            else
              # Subcats are null for the category in the categories json
              # means prices will be apply for all subcats except except_subcats
              Rails.logger.info "No subcategories in ebay pricing table"
              if cat_json["except_subcats"].present?
                Rails.logger.info "Except subcats need to check for the product's subcategories"
                # prices will only be apply if product's subcategory will not present in except_subcats
                cat_json["except_subcats"].each do |ex_sb|
                  if product.sub_categories.to_s.include?(ex_sb)
                    # If product's subcategory matched with any of except_subcats, prices will not apply
                    is_category_matched = false
                    # stop here now
                    Rails.logger.info "Product's subcategory is available in except subcategoy. Category is not matching now"
                    break
                  end
                end

                # If no except_subcats means category matched and prices will be apply for all
                # is_category_matched = true by default
              end
            end

            # Now check if product category is matching or not
            if is_category_matched
              # If matching with some category then apply price for same
              Rails.logger.info "Finally Category matched "
              Rails.logger.info "Applying product's category percentage"
              @percentage = comparable_product_percent(comparable_product, category_prices)
            else
              # If not matching with any of category apply price for all_other (default category)
              Rails.logger.info "Finally category not matched"
              Rails.logger.info "Applying default category percentage"
              @percentage = comparable_product_percent(comparable_product, default_category_prices)
            end
          else
            # If category_data not exists in categories json apply price for all_other (default category)
            # worst case
            Rails.logger.info "Product category's pricing data not found in json"
            Rails.logger.info "Applying default category percentage"
            @percentage = comparable_product_percent(comparable_product, default_category_prices)
          end
        else
          # If category_title not exists in categories json apply price for all_other (default category)
          # default_category_data
          Rails.logger.info "Product category not found in ebay categories"
          Rails.logger.info "Applying default category percentage"
          @percentage = comparable_product_percent(comparable_product, default_category_prices)
        end

        Rails.logger.info "Total price: #{total_price}"
        Rails.logger.info "Percentage: #{@percentage}"
        
        # Worst case
        @percentage = 3 if @percentage.to_f<=0

        fee_amount = (total_price * ((@percentage / 100) rescue 1) rescue 0).round(1)
        gross_revenue = (total_price - fee_amount rescue 0).round(1)
        net_revenue = (gross_revenue - comparable_product.try(:shipping_cost) rescue 0).round(1)
        Rails.logger.info "--- gross_revenue ---  #{gross_revenue}"
        Rails.logger.info "--- net_revenue --- #{net_revenue}"
        comparable_product.ebay_fee_amount = fee_amount || 0.0
        comparable_product.ebay_fee_percantage = @percentage || 0.0
        comparable_product.ebay_gross_revenue = gross_revenue || 0.0
        comparable_product.save

        Rails.logger.info "... Comparable Product EBAY FEE AMOUNT ... #{comparable_product.ebay_fee_amount}"
        Rails.logger.info "... Comparable Product EBAY FEE PERCANTAGE ... #{comparable_product.ebay_fee_percantage}"
        Rails.logger.info "... Comparable Product EBAY GROSS REVENUE ... #{comparable_product.ebay_gross_revenue}"

        # NEW CONDITION ADDED START
        prices = product.comparable_products.pluck(:price) rescue []

        prices.reject { |price| (price.blank? || price == 0 || price == 0.0) }
        
        #  REMOVE MIN AND MAX PRICE
        max_bid_price = prices.delete(prices.max) rescue []
        min_bid_price = prices.delete(prices.min) rescue []
        
        # CALCULATE AVERAGE EBAY PRODUCT PRICE
        average_prices = (prices.sum / prices.size rescue 0)
        product.update(max_bid_price: max_bid_price, min_bid_price: min_bid_price, ebay_profit_estimate: average_prices)
      end
      break if index==1
    end

    render json: { code: 200, message: "Data refined successfully" }
  end

  private

  def ebay_scraper product_name
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
        "goog:chromeOptions": {
        args: %w[headless no-sandbox enable-features=NetworkService,NetworkServiceInProcess]
        })
    driver = Selenium::WebDriver.for(:chrome, capabilities: caps)
    driver.get('https://www.ebay.com/sch/ebayadvsearch')
    puts driver.title
    driver.find_element(id: '_nkw').send_keys(product_name)
    driver.find_element(id: "LH_Complete").click
    driver.find_element(id: "searchBtnLowerLnk").click
    puts driver.current_url
    search_data = []
    begin
      categories = driver.find_element(class: 'catsgroup').text.to_s.split("/n") rescue []
      driver.find_elements(class: 'li').each_with_index do |item, ind|
        element_html = item.attribute("innerHTML").to_s.gsub("\n","").gsub("\t","").gsub(/[\"]/,"")
        page = Nokogiri::HTML(element_html)
        in_range = page.css("ul.lvprices li.lvprice span.prRange")&.text
        if in_range.to_s.strip.present?
          amount = in_range.to_s.split(" to ").first.to_s
          currency = amount_currency(amount)
          min_price = in_range.to_s.split(" to ").first.to_s.gsub(currency,"").to_f
          max_price = in_range.to_s.split(" to ").last.to_s.gsub(currency,"").to_f
          main_price = ((min_price+max_price)/2).round(2)
        else
          new_price = (page.css("ul.lvprices li.lvprice span").text rescue nil)
          if new_price.to_s.strip.present?
            if (new_price.to_s.include?("Was:") or new_price.to_s.include?("Previous Price"))
              main_price = (page.css("ul.lvprices li.lvprice span.bidsold").text rescue nil)
              if !main_price.present?
                main_price = (new_price.to_s.split(".").first+'.'+new_price.to_s.split(".").last&.first(2))
              end
            else
              main_price = new_price
            end
          else
            main_price = (page.css("ul.lvprices li.lvprice span.bidsold").text rescue nil)
          end
          currency = amount_currency(main_price)
        end
        ebay_id = (page.css('.lvpic').attr("iid").value rescue nil)
        title = (page.at_css(".vip").text rescue nil)
        ebay_product_link = (page.css(".vip").attr("href").value rescue nil)
        image_link = (page.css(".lvpicinner img").attr("src").value rescue nil)

        sub_title = (page.at_css(".lvsubtitle").text rescue nil)
        shipping_cost = (page.at_css(".fee").text rescue nil)

        if title.present? and main_price.present? and ebay_id.present?
          if !categories.present?
            begin
              doc = Nokogiri::HTML(URI.open(ebay_product_link))
              doc.css('nav ul li a span').each do |span_text|
                unless (span_text.children.text == "Email to friends" || span_text.children.text == "Share on Facebook - opens in a new window or tab" || span_text.children.text == "Share on Twitter - opens in a new window or tab" || span_text.children.text =="Share on Pinterest - opens in a new window or tab")
                  categories << span_text.children.text
                end
              end
            rescue => e
            end
          end
          search_data << {
                ebay_id: ebay_id,
                title: title,
                sub_title: sub_title,
                image_link: image_link,
                price: main_price.to_s.gsub(currency,'').to_f,
                currency: currency,
                shipping_cost: shipping_cost.to_s.gsub("$",'').to_f,
                ebay_product_link: ebay_product_link,
                categories: categories
              }
        end
      end
      if search_data.count==0
        @retry_count+=1
        driver.quit
        ebay_scraper(modify_product_title(product_name)) if @retry_count<=1
      else
        driver.quit
      end
      
    rescue => e
      @retry_count+=1
      driver.quit
      ebay_scraper(modify_product_title(product_name)) if @retry_count<=1
    end
    search_data
  end

  def get_category_price_data data_arr, cat_title
    data = nil
    data_arr.each do |cat_data|
      cat_found  = false
      cat_data["categories"].each do |cat|
        if cat["title"]==cat_title
          data = {data: cat_data, category_info: cat}
          cat_found = true
          break
        end
      end
      break if cat_found
    end
    data
  end

  def comparable_product_percent cprod, cat_data
    if cat_data["amount_upto"].present?
      if cprod.price.to_f<=cat_data["amount_upto"].to_f
        # If product amount less than amount upto, percent_upto will be apply
        cat_data["percent_upto"].to_f
      else
        # If product amount greater than amount upto, check in over_sales
        if cat_data["over_sales"].present?
          percent = 0
          percent_applied = false
          cat_data["over_sales"].each do |ovr|
            if (cprod.price.to_f>=ovr["min_amount"].to_f and !ovr["max_amount"].present?)
              # "max_amount" not present means there is not last range limit for this percent
              percent = ovr["cut_percent"].to_f
              percent_applied = true
              # stop here
              break
            elsif ovr["max_amount"].present?
              if (cprod.price.to_f>=ovr["min_amount"].to_f and cprod.price.to_f<=ovr["max_amount"].to_f)
                # If product amount is found in range
                percent = ovr["cut_percent"].to_f
                percent_applied = true
                # stop here
                break
              end
            end
          end

          if !percent_applied
            # worst case
            # If no over_sales than apply percent_upto
            percent = cat_data["percent_upto"].to_f
          end
          percent
        else
          # worst case
          # If no over_sales than apply percent_upto
          cat_data["percent_upto"].to_f
        end
      end
    else
      # "amount_upto": null means percent_upto percent will be apply of all amount no need to check over_sales
      cat_data["percent_upto"].to_f
    end
  end

  def search_on_ebay product
    @retry_count = 0
    # ebay_scraper(product.name, product.manifest.auction.auction_zip)
    products = ebay_scraper(product.name)
    if products.count>0
      # product.update(has_comparables: true)
        
      products.each_with_index do |item,ind|
        data = { 
          store_type: item[:ebay_id], 
          name: item[:title],
          image_link: item[:image_link], 
          store_link: item[:ebay_product_link],
          price: item[:price].to_f, 
          currency: item[:currency],
          condition: item[:sub_title],
          shipping_cost: item[:shipping_cost].to_f,
          product_id: product.id,
          category: item[:categories].first,
          sub_categories: item[:categories].join(", ")
        }
        comp = ComparableProduct.where(product_id: product.id, store_link: item[:ebay_product_link]).first
        if comp 
          comp.update(data)
        else
          ComparableProduct.create(data)
        end
      end
    end
  end

  def modify_product_title(product_title)
    stopwords = Array.new
    stopwords = File.read(Rails.root.join("lib/tasks/data", "stop_words.txt")).split(",").map(&:strip)
    filter_a = Stopwords::Filter.new stopwords
    product_name = filter_a.filter product_title.split
    product_name = product_name.join(" ").gsub("/", " ").gsub("-", " ").split(" ").first(8).join(" ")
  end
  
  def amount_currency amount
    currency = ""
    amount.split("").each do |chr|
      if chr.match?(/[[:digit:]]/)
        break
      else
        currency = currency+chr
      end
    end
    currency
  end

  def find_product
    @product = Product.find_by_id(params[:product_id])
    return render json: { code: 404, message: "Product does not exists" }, status: 404 unless @product
  end
end
