class HappycowScrapersController < ApplicationController

  def create
    begin
      browser = Watir::Browser.new :chrome, driver_path: '/usr/bin/chromedriver'
      total_pages_count = 1

      begin
        siteurls.each do |url|

          browser.goto url
          sleep random_second_interval

          page_data = Nokogiri::HTML(browser.html)

          total_pages = page_data.at_css('.total-listings').present? ? page_data.at_css('.total-listings').text.gsub("(","").gsub(")","") : ""
          item_list = page_data.css(".panel--region")

          if item_list.present?

            begin
              pages_count = total_pages.to_f/item_list.count
              total_pages_count = pages_count.to_f % 1 != 0 ? pages_count.to_i+1 : pages_count.to_i 
              
              for i in 1..total_pages_count

                begin
                  
                  if i !=1
                    siteurl = "#{url}?page=#{i}"
                    page_html = PageHtml.find_by_page_url(siteurl)
                  else
                    page_html = PageHtml.find_by_page_url(url)
                  end
                  
                  if !page_html
                    browser.goto siteurl
                    sleep random_second_interval

                    page_data = Nokogiri::HTML(browser.html)
                    item_list = page_data.css(".panel--region")

                    PageHtml.create!(page_url: siteurl, html_code: page_data)

                    item_list.each_with_index do |ele,ind|

                      begin
                        if ele.at_css('.link').present?
                          rname = ele.at_css('.link').text
                          plink = ele.at_css('.link')["href"]
                          rid = plink.present? ? plink.split("-").last : ""
                        end 
                        restaurant = PageItem.find_by_r_id(rid)
                        if !restaurant
                          totalReviews = ele.at_css('.hidden-sm~ .hidden-sm+ .hidden-sm').present? ? ele.at_css('.hidden-sm~ .hidden-sm+ .hidden-sm').text : ""
                          location = ele.at_css('.xsmt--1').present? ? ele.at_css('.xsmt--1').text : ""
                          contact = ele.at_css('.fa-phone+ a').present? ? ele.at_css('.fa-phone+ a').text : ""
                          timing = ele.at('.venue-hours-container').present? ? ele.at('.venue-hours-container')["data-summary"] : ""
                          cuisine = ele.at_css('p:nth-child(6)').present? ? ele.at_css('p:nth-child(6)').text : ""
                          details = ele.at_css('.region__element__data+ .region__element p').present? ? ele.at_css('.region__element__data+ .region__element p').text : "" 
                          pageItem = PageItem.create!(r_id:rid,r_name:rname,p_link:plink,location:location,contact:contact,timing:timing,cuisine:cuisine,details:details,total_reviews:totalReviews,item_html_code:item_list)
                        end
                      rescue Exception => e
                        Rails.logger.info e
                        Error.create(error: e, message: "happycow", url: siteurl)
                      end 
                    end
                  end
                  
                rescue Exception => e
                  Rails.logger.info e
                  Error.create(error:e,message:"happycow",url:siteurl)
                end
              end

            rescue Exception => e
              Rails.logger.info e
              Error.create(error: e, message: "happycow", url: url)
            end

          end
        end

      rescue Exception => e
        Rails.logger.info e
        Error.create(error: e, message: "happycow", url: url)
      end

    rescue Exception => e
      Rails.logger.info e
      Error.create(error: e, message: "happycow", url: "main page in per page")
    end
  end

  private

  def siteurls
    [
      "https://www.happycow.net/europe/england/london/",
      "https://www.happycow.net/europe/germany/berlin/",
      "https://www.happycow.net/north_america/usa/new_york/new_york_city/",
      "https://www.happycow.net/north_america/usa/oregon/portland/",
      "https://www.happycow.net/asia/israel/tel_aviv/",
      "https://www.happycow.net/north_america/usa/california/los_angeles/",
      "https://www.happycow.net/north_america/canada/ontario/toronto/",
      "https://www.happycow.net/europe/czech_republic/prague/",
      "https://www.happycow.net/europe/france/paris/",
      "https://www.happycow.net/europe/poland/warsaw/"
    ]
  end

  def random_second_interval
    [12, 10, 8, 7, 5, 11].sample
  end
end
