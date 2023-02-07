class VanillaScrapersController < ApplicationController
  
  def create
    begin
      siteurls.each do |url|

        pageData = Nokogiri::HTML(open(url))

        total_page_html = pageData.at_css('.localities-index-list')
        itemList = pageData.css('.localities-index-list')

        begin

          if itemList.present?

            href_link_data = itemList.css('a')
            pages_count = itemList.at_css('.total-pages')
            total_pages_count = pages_count.to_f % 1 != 0 ? pages_count.to_i+1 : pages_count.to_i 

            begin

              for i in 1..total_pages_count

                if i !=1
                  siteurl = "#{url}&offset=#{i*20-20}"
                  page_html = VanillaPageHtml.find_by_page_url(siteurl)
                else
                  page_html = VanillaPageHtml.find_by_page_url(url)
                end

                begin

                  if !page_html

                    if siteurl.present?
                      pageData = Nokogiri::HTML(open(siteurl))
                      itemList = pageData.css('.localities-index-list')
                      href_link_data = itemList.css('a')
                      vanilla_page_html = VanillaPageHtml.create!(page_url:siteurl,html_code:pageData)
                    else
                      vanilla_page_html = VanillaPageHtml.create(page_url:url,html_code:pageData) 
                    end

                    begin
                      href_link_data.each do |link|

                        href_link = link['href']
                        profile_url = "https://www.vanilla-bean.com/#{href_link}"
                        profile_data = Nokogiri::HTML(open(profile_url))

                        rid = href_link.split("/")[2]
                        restaurant = VanillaPageItem.find_by_r_id(rid)

                        if !restaurant
                          image = profile_data.at_css('.web-application-image-with-meta-image').present? ? profile_data.at_css('.web-application-image-with-meta-image')['src'] : ""
                          rname = profile_data.at_css('.localities-show-meta-title').present? ? profile_data.at_css('.localities-show-meta-title').text : ""

                          if profile_data.at_css('.localities-show-info-contact-data dd:nth-child(2) a').present?
                            location = profile_data.at_css('.localities-show-info-contact-data dd:nth-child(2) a').text
                            val = profile_data.at_css('.localities-show-info-contact-data dd:nth-child(2) a')['href'].split("=")
                            latitude = val.present? ? val[1].split(",")[0] : ""
                            longitude = val.present? ? val[1].split(",")[1] : ""
                          end

                          slogan = profile_data.at_css('.localities-show-meta-slogan').present? ? profile_data.at_css('.localities-show-meta-slogan').text : ""
                          contact = profile_data.at_css('.localities-show-info-contact-data dd~ dd a').present? ? profile_data.at_css('.localities-show-info-contact-data dd~ dd a').text : ""
                          details = profile_data.at_css('.localities-show-info-editorial p').present? ? profile_data.at_css('.localities-show-info-editorial p').text : ""
                          cuisine = profile_data.at_css('.localities-show-meta-categories').present? ? profile_data.at_css('.localities-show-meta-categories').text : ""
                          facebookLink = profile_data.at_css('.localities-show-links dd~ dd a').present? ? profile_data.at_css('.localities-show-links dd~ dd a').text : ""
                          websiteLink = profile_data.at_css('.localities-show-links dd:nth-child(2) a').present? ? profile_data.at_css('.localities-show-links dd:nth-child(2) a').text : ""
                          price_category = profile_data.at_css('.localities-show-meta-info-price-category').present? ? profile_data.at_css('.localities-show-meta-info-price-category').text : ""

                          timing = profile_data.at_css('.localities-show-info-openings').present? ? profile_data.at_css('.localities-show-info-openings').text : ""

                          VanillaPageItem.create!({
                            vanilla_page_html_id: vanilla_page_html.id,
                            r_id: rid,
                            r_name: rname,
                            item_page_link: profile_url,
                            item_html_code: profile_data,
                            image: image,
                            price: price_category,
                            slogan: slogan,
                            location: location,
                            latitude: latitude,
                            longitude: longitude,
                            contact: contact,
                            timing: timing,
                            cuisine: cuisine,
                            details: details,
                            facebook_link: facebookLink,
                            website_link: websiteLink,
                            total_reviews: totalReviews
                          })
                        end 
                        #end of restaurant if loop (present or not)

                      end 
                      #end href link each loop

                    rescue Exception => e
                      Error.create(error: e, message: "vanilla-bean", url: href_link)
                    end
                  end
                rescue Exception => e
                  Error.create(error: e, message: "vanilla-bean", url: siteurl)
                end
              end
            rescue Exception => e
              Error.create(error: e, message: "vanilla-bean", url: siteurl)
            end
          end
        rescue Exception => e
          Error.create(error: e, message: "vanilla-bean", url: url)
        end
      end
    rescue Exception => e
      Error.create(error:e, message:"vanilla-bean")
    end
  end

  private

  def siteurls
    [
      "https://www.vanilla-bean.com/localities?content_title=Troyes&geo%5B%5D=4.0744009&geo%5B%5D=48.2973451",
      "https://www.vanilla-bean.com/localities?content_title=Bordeaux&geo%5B%5D=-0.57918&geo%5B%5D=44.837789",
      "https://www.vanilla-bean.com/localities?content_title=London&geo%5B%5D=-0.1277583&geo%5B%5D=51.5073509",
      "https://www.vanilla-bean.com/localities?content_title=Dublin&geo%5B%5D=-6.2603097&geo%5B%5D=53.3498053"
    ]
  end
end
