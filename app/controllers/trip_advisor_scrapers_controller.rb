class TripAdvisorScrapersController < ApplicationController
  def trip_advisor
    url = "https://www.tripadvisor.in/Restaurants-g4-Europe.html"
    main_page_data = Nokogiri::HTML(open(url))

    sleep random_second_interval

    total_page = main_page_data.at_css('.separator+ a').present? ? main_page_data.at_css('.separator+ a').text.to_i : 0
      
    trip_advisor_main_page_html = TripAdvisorMainPageHtml.find_by(page_url:url)
    trip_advisor_main_page_html = TripAdvisorMainPageHtml.create!(page_url: url, page_html: main_page_data) if !trip_advisor_main_page_html.present?
    
    for i in 1..total_page

      if i==1
        begin
          mainPageHtml = main_page_data.at_css('.geos_grid')

          if mainPageHtml.present?

            pageHtml = main_page_data.css('.geo_wrap')

            pageHtml.each do |pHtml|

              geo_name_href = pHtml.at_css('.geo_name a').present? ? pHtml.at_css('.geo_name a')["href"] : ""
              pageUrl = "https://www.tripadvisor.in#{geo_name_href}"

              trip_advisor_html_data =  TripAdvisorHtml.find_by_page_url(pageUrl) 
              
              if !trip_advisor_html_data
                page_data = Nokogiri::HTML(open(pageUrl))
                sleep random_second_interval

                total_pages = page_data.at_css('.popIndexDefault').present? ? page_data.at_css('.popIndexDefault').text.split(" ")[2].gsub(",","") : ""  #css('div #EATERY_LIST_CONTENTS') #EATERY_SEARCH_RESULTS
                itemList = page_data.css('.listing')
 
                trip_advisor_html = TripAdvisorHtml.create!(page_url:pageUrl,page_html:page_data,trip_advisor_main_page_html_id:trip_advisor_main_page_html.id)
                
                if itemList.present?

                  pages_count = total_pages.to_f/(itemList.count-1)
                  total_pages_count = pages_count.to_f % 1 != 0 ? pages_count.to_i+1 : pages_count.to_i 
                  
                  begin

                    for i in 1..total_pages_count
                      if i !=1
                        sec_url1 = pageUrl.split("-")
                        siteurl = "#{sec_url1[0]}"+"-"+"#{sec_url1[1]}"+"-oa"+"#{i*30-30}"+"-"+"#{sec_url1[2]}"
                      end


                      if siteurl.present?
                        page_data = Nokogiri::HTML(open(siteurl))
                        itemList = page_data.css('.listing')
                        href_link_data = itemList.css('a')
                        trip_advisor_html = TripAdvisorHtml.create!(page_url: siteurl,page_html: page_data, trip_advisor_main_page_html_id: trip_advisor_main_page_html.id)
                      end

                      itemList.each do |i|
                        
                        data = i.at_css(".listingIndex-n")
                        href_url = i.at_css('.photo_booking').present? ? i.at_css('.photo_booking').at_css('a')["href"] : ""
                        
                        if href_url

                          profileUrl = "https://www.tripadvisor.in#{href_url}"
                          
                          profileData = Nokogiri::HTML(open(profileUrl))
                          rid = profileUrl.split("-")[2]
                          restaurant = TripAdvisorItem.find_by_r_id(rid)

                          if !restaurant
                            rname = profileData.at_css('.h1').present? ? profileData.at_css('.h1').text : ""
                            totalReviews = profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__ratingCount--DFxkG').present? ? profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__ratingCount--DFxkG').text : ""
                            totalRating = profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__overallRating--nohTl').present? ? profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__overallRating--nohTl').text : ""
                            timing = profileData.at_css('.public-location-hours-LocationHours__bold--2oLr-+ span').present? ? profileData.at_css('.public-location-hours-LocationHours__bold--2oLr-+ span').text : "" 
                            image = profileData.at_css('.large_photo_wrapper .basicImg').present? ? profileData.at_css('.large_photo_wrapper .basicImg')['src'] : ""
                            detailsHtml = profileData.css('.restaurants-details-card-DetailsCard__wrapperDiv--vS1lQ') 
                            
                            if detailsHtml.present?
                              price = detailsHtml.at_css('.restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                              cuisine = detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div:nth-child(1) .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div:nth-child(1) .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                              details = detailsHtml.at_css('.restaurants-details-card-DesktopView__desktopAboutText--1VvQH').present? ? detailsHtml.at_css('.restaurants-details-card-DesktopView__desktopAboutText--1VvQH').text : ""
                              features = detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                              special_diet = detailsHtml.at_css('.ui_column:nth-child(2) div:nth-child(2) .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column:nth-child(2) div:nth-child(2) .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                              meals = detailsHtml.at_css('div~ div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('div~ div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').text : ""
                            end

                            locationHTML = profileData.css('.is-4-desktop~ .is-4-desktop+ .is-4-desktop .restaurants-detail-overview-cards-DetailOverviewCards__wrapperDiv--1Dfhf')
                            
                            if locationHTML.present?
                              location = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLinkText--co3ei').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLinkText--co3ei').text : "" 
                              contact = profileData.at_css('.detail.is-hidden-mobile').present? ? profileData.at_css('.detail.is-hidden-mobile').text : ""
                              email = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLink--iyzJI restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6 span a').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLink--iyzJI restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6 span a') : ""
                              websiteLink = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6') : ""
                              websiteLink = locationHTML.at_css('')
                            end

                            TripAdvisorItem.create!({
                              trip_advisor_html_id: trip_advisor_html.id,
                              r_id: rid,
                              r_name: rname,
                              item_page_url: profileUrl,
                              item_page_html: profileData,
                              image: image,
                              price: price,
                              location: location,
                              latitude: latitude,
                              longitude: longitude,
                              contact: contact,
                              email: email,
                              timing: timing,
                              cuisine: cuisine,
                              meals: meals,
                              special_diet: special_diet,
                              features: features,
                              details: details,
                              website_link: websiteLink
                            })
                          end
                        end
                      end
                      # changes here for pagination
                    end
                  rescue Exception => e
                    Error.create(error:e,message:"Trip Advisor in in siteurls profileUrl if loop")
                  end
                end
              end
            end
          end
        rescue Exception => e
          Error.create(error:e,message:"Trip Advisor in siteurls pageHtml2 if loop")
        end

      else
        sec_url = url.split("-")
        second_url = "#{sec_url[0]}"+"-"+"#{sec_url[1]}"+"-oa"+"#{i*20-20}"+"-"+"#{sec_url[2]}"+"#LOCATION_LIST"
        
        begin
          main_page_data2 = Nokogiri::HTML(open(second_url))
          trip_advisor_main_page_html = TripAdvisorMainPageHtml.find_by(page_url:second_url)
          trip_advisor_main_page_html = TripAdvisorMainPageHtml.create!(page_url:url,page_html:main_page_data) if !trip_advisor_main_page_html
          
          mainPageHtml2 = main_page_data2.at_css('.balance')
          
          if mainPageHtml2.present?
            total_page2 = main_page_data2.at_css('.ollie+ .deckTools .pgCount').present? ? main_page_data2.at_css('.ollie+ .deckTools .pgCount').text.split(" ")[2].gsub(",","") : 0
            pageHtml2 = main_page_data2.css('#LOCATION_LIST li a')
            
            begin
              if pageHtml2.present?
                pages_count = total_page2.to_f/pageHtml2.count
                total_pages_count = pages_count.to_f % 1 != 0 ? pages_count.to_i+1 : pages_count.to_i 
                
                begin
                  pageHtml2.each do |pageHtml|

                    href2 = pageHtml["href"]
                    href_link2 = "https://www.tripadvisor.in#{href2}"

                    page_data2 = Nokogiri::HTML(open(href_link2))
                    trip_advisor_html = TripAdvisorHtml.create!(page_url:href_link2,page_html:page_data2,trip_advisor_main_page_html_id:trip_advisor_main_page_html.id)
                    total_pages2 = page_data2.at_css('.popIndexDefault').present? ? page_data2.at_css('.popIndexDefault').text.split(" ")[2].gsub(",","") : ""
                    itemList2 = page_data2.css('.listing')
                    
                    if itemList2.present?

                      pages_count2 = total_pages2.to_f/(itemList2.count-1)
                      total_pages_count2 = pages_count2.to_f % 1 != 0 ? pages_count2.to_i+1 : pages_count2.to_i 
                      
                      begin 
                        for i in 1..total_pages_count2
                          if i !=1
                            sec_url2 = href_link2.split("-")
                            siteurl = "#{sec_url2[0]}"+"-"+"#{sec_url2[1]}"+"-oa"+"#{i*30-30}"+"-"+"#{sec_url2[2]}"
                            trip_advisor_html_data = TripAdvisorHtml.find_by_page_url(siteurl)
                          end

                          if !trip_advisor_html_data
                            begin
                              
                              if siteurl.present?
                                page_data = Nokogiri::HTML(open(siteurl))
                                itemList2 = page_data.css('.listing')
                                trip_advisor_html = TripAdvisorHtml.create!(page_url:siteurl,page_html:page_data,trip_advisor_main_page_html_id:trip_advisor_main_page_html.id)
                              end
                              
                              itemList2.each do |i|
                                data = i.at_css(".listingIndex-n")
                                href_url = i.at_css('.photo_booking').present? ? i.at_css('.photo_booking').at_css('a')["href"] : ""
                                
                                if href_url
                                  profileUrl = "https://www.tripadvisor.in#{href_url}"
                                  profileData = Nokogiri::HTML(open(profileUrl))
                                  
                                  rid = profileUrl.split("-")[2]
                                  restaurant = TripAdvisorItem.find_by_r_id(rid)
                                  
                                  if !restaurant
                                    rname = profileData.at_css('.h1').present? ? profileData.at_css('.h1').text : ""
                                    totalReviews = profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__ratingCount--DFxkG').present? ? profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__ratingCount--DFxkG').text : ""
                                    totalRating = profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__overallRating--nohTl').present? ? profileData.at_css('.restaurants-detail-overview-cards-RatingsOverviewCard__overallRating--nohTl').text : ""
                                    timing = profileData.at_css('.public-location-hours-LocationHours__bold--2oLr-+ span').present? ? profileData.at_css('.public-location-hours-LocationHours__bold--2oLr-+ span').text : "" 
                                    image = profileData.at_css('.large_photo_wrapper .basicImg').present? ? profileData.at_css('.large_photo_wrapper .basicImg')['src'] : ""
                                    detailsHtml = profileData.css('.restaurants-details-card-DetailsCard__wrapperDiv--vS1lQ') 
                                    
                                    if detailsHtml.present?
                                      price = detailsHtml.at_css('.restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                                      cuisine = detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div:nth-child(1) .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div:nth-child(1) .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                                      details = detailsHtml.at_css('.restaurants-details-card-DesktopView__desktopAboutText--1VvQH').present? ? detailsHtml.at_css('.restaurants-details-card-DesktopView__desktopAboutText--1VvQH').text : ""
                                      features = detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column~ .ui_column+ .ui_column div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                                      special_diet = detailsHtml.at_css('.ui_column:nth-child(2) div:nth-child(2) .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('.ui_column:nth-child(2) div:nth-child(2) .restaurants-details-card-TagCategories__tagText--Yt3iG').text : "" 
                                      meals = detailsHtml.at_css('div~ div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').present? ? detailsHtml.at_css('div~ div+ div .restaurants-details-card-TagCategories__tagText--Yt3iG').text : ""
                                    end
                                    
                                    locationHTML = profileData.css('.is-4-desktop~ .is-4-desktop+ .is-4-desktop .restaurants-detail-overview-cards-DetailOverviewCards__wrapperDiv--1Dfhf')
                                    
                                    if locationHTML.present?
                                      location = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLinkText--co3ei').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLinkText--co3ei').text : "" 
                                      contact = profileData.at_css('.detail.is-hidden-mobile').present? ? profileData.at_css('.detail.is-hidden-mobile').text : ""
                                      email = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLink--iyzJI restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6 span').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__detailLink--iyzJI restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6 span') : ""
                                      websiteLink = locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6').present? ? locationHTML.at_css('.restaurants-detail-overview-cards-LocationOverviewCard__contactItem--1flT6') : ""
                                    end
                                    
                                    TripAdvisorItem.create!(trip_advisor_html_id:trip_advisor_html.id,r_id:rid,r_name:rname,item_page_url:profileUrl,item_page_html:profileData,image:image,price:price,location:location,latitude:latitude,longitude:longitude,contact:contact,email:email,timing:timing,cuisine:cuisine,meals:meals,special_diet:special_diet,features:features,details:details,website_link:websiteLink)
                                  end
                                
                                end # end if loop of clicking single restaurant
                              
                              end# end of for loop
                            
                            rescue Exception => e
                              Error.create(error:e,message:"tripAdvisor in siteurls pageHtml2 if loop",url:siteurl)
                            end
                          end
                        end
                      rescue Exception => e
                        Error.create(error:e,message:"tripAdvisor",url:sec_url2)
                      end
                    end
                  end
                rescue Exception => e
                  Error.create(error:e,message:"tripAdvisor")
                end
              end # end if loop pageHtml2 present
            rescue Exception => e
              Error.create(error:e,message:"tripAdvisor in siteurls pageHtml2 if loop")
            end
          end 
          # end of mainpagehtml2 data

        rescue Exception => e
          Error.create(error: e, message: "tripAdvisor", url: second_url)
        end
      end
    end
  end

  private

  def random_second_interval
    [12, 10, 8, 7, 5, 11].sample
  end
end
