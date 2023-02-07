class WelcomeController < ApplicationController
	require 'nokogiri'
	require 'open-uri'
	require "watir"

	# happ cow
	

	def vanilla_beans
		begin
			# siteurls = ["https://www.vanilla-bean.com/localities?content_title=Phoenix&geo%5B%5D=-112.0740373&geo%5B%5D=33.4483771",
			# 	"https://www.vanilla-bean.com/localities?content_title=Berlin&geo%5B%5D=13.404954&geo%5B%5D=52.52000659999999",
			# 	"https://www.vanilla-bean.com/localities?content_title=Glasgow&geo%5B%5D=-4.251806000000001&geo%5B%5D=55.864237",
			# 	"https://www.vanilla-bean.com/localities?content_title=Troyes&geo%5B%5D=4.0744009&geo%5B%5D=48.2973451",
			# 	"https://www.vanilla-bean.com/localities?content_title=Bordeaux&geo%5B%5D=-0.57918&geo%5B%5D=44.837789",
			# 	"https://www.vanilla-bean.com/localities?content_title=London&geo%5B%5D=-0.1277583&geo%5B%5D=51.5073509",
			# 	"https://www.vanilla-bean.com/localities?content_title=Dublin&geo%5B%5D=-6.2603097&geo%5B%5D=53.3498053"]
			
			siteurls.each do |url|
				# url = "https://www.vanilla-bean.com/localities?content_title=Troyes&geo%5B%5D=4.0744009&geo%5B%5D=48.2973451"
				pageData = Nokogiri::HTML(open(url))
				# sleep 1
				total_page_html = pageData.at_css('.localities-index-list')
				itemList = pageData.css('.localities-index-list') #('.localities-index-locality')#.present?	
				begin
					if itemList.present?
						href_link_data = itemList.css('a')#[0]['href']
						pagesCount = 33289/2
						totalPagesCount = pagesCount.to_f % 1 != 0 ? pagesCount.to_i+1 : pagesCount.to_i 
						begin
							for i in 1..totalPagesCount
								# p "@@@@@@@@@@@@@@@@=====i-----==#{i}======offset===#{i*20-20}===000000000000"
								if i !=1
									siteurl = "#{url}&offset=#{i*20-20}"
									page_html = VanillaPageHtml.find_by_page_url(siteurl)
								else
									page_html = VanillaPageHtml.find_by_page_url(url)
								end
								# p "=========page_html=========#{page_html.inspect}====="
								begin
									if !page_html
										if siteurl.present?
											pageData = Nokogiri::HTML(open(siteurl))
											# sleep 1
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
												profileData = Nokogiri::HTML(open(profile_url))
												# sleep 2
										    image = ""
										    rname =""
												rid = ""
												plink = ""
												location = ""
												latitude = ""
												longitude = ""
												contact = ""
												timing = ""
												cuisine = ""
												details = ""
												totalReviews = ""
												facebookLink = ""
												websiteLink = ""
												price = ""
												rid = href_link.split("/")[2] #itemList['data-hover-locality-id'].present? ? itemList['data-hover-locality-id'] : ""
												# p "====rid======#{rid}====="
												restaurant = VanillaPageItem.find_by_r_id(rid)
												# p "======restaurant------------------#{restaurant.inspect}==========="
												if !restaurant
													image = profileData.at_css('.web-application-image-with-meta-image').present? ? profileData.at_css('.web-application-image-with-meta-image')['src'] : ""
													rname = profileData.at_css('.localities-show-meta-title').present? ? profileData.at_css('.localities-show-meta-title').text : ""
													# p "===rname====#{rname}===="
													if profileData.at_css('.localities-show-info-contact-data dd:nth-child(2) a').present?
														location = profileData.at_css('.localities-show-info-contact-data dd:nth-child(2) a').text
														val = profileData.at_css('.localities-show-info-contact-data dd:nth-child(2) a')['href'].split("=")
														latitude = val.present? ? val[1].split(",")[0] : ""
														longitude = val.present? ? val[1].split(",")[1] : ""
													end
													slogan = profileData.at_css('.localities-show-meta-slogan').present? ? profileData.at_css('.localities-show-meta-slogan').text : ""
													contact = profileData.at_css('.localities-show-info-contact-data dd~ dd a').present? ? profileData.at_css('.localities-show-info-contact-data dd~ dd a').text : ""
													details = profileData.at_css('.localities-show-info-editorial p').present? ? profileData.at_css('.localities-show-info-editorial p').text : ""
													cuisine = profileData.at_css('.localities-show-meta-categories').present? ? profileData.at_css('.localities-show-meta-categories').text : ""
													facebookLink = profileData.at_css('.localities-show-links dd~ dd a').present? ? profileData.at_css('.localities-show-links dd~ dd a').text : ""
													websiteLink = profileData.at_css('.localities-show-links dd:nth-child(2) a').present? ? profileData.at_css('.localities-show-links dd:nth-child(2) a').text : ""
													price_category = profileData.at_css('.localities-show-meta-info-price-category').present? ? profileData.at_css('.localities-show-meta-info-price-category').text : ""
													# totalReviews = profileData.at_css('.localities-show-meta-info-price-category').present? ? profileData.at_css('.localities-show-meta-info-price-category').text : ""
													# p "====price=====#{price_category}===="
													timing = profileData.at_css('.localities-show-info-openings').present? ? profileData.at_css('.localities-show-info-openings').text : ""
													VanillaPageItem.create!(vanilla_page_html_id:vanilla_page_html.id,r_id:rid,r_name:rname,item_page_link:profile_url,item_html_code:profileData,image:image,price:price_category,slogan:slogan,location:location,latitude:latitude,longitude:longitude,contact:contact,timing:timing,cuisine:cuisine,details:details,facebook_link:facebookLink,website_link:websiteLink,total_reviews:totalReviews)
												end #end of restaurant if loop (present or not)
											end #end href link each loop
										rescue Exception => e
											p "XXXXXXXXXXXXXXXXXXXXXXX in each loop of href_link_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
											p e
											Error.create(error:e,message:"vanilla-bean",url:href_link)
											p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
										end
									end
								rescue Exception => e
									p "XXXXXXXXXXXXXXXXXXXXXXX in if !page_html XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
									p e
									Error.create(error:e,message:"vanilla-bean",url:siteurl)
									p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
								end
							end
						rescue Exception => e
							p "XXXXXXXXXXXXXXXXXXXXXXX in for loop XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
							p e
							Error.create(error:e,message:"vanilla-bean",url:siteurl)
							p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
						end
					end
				rescue Exception => e
					p "XXXXXXXXXXXXXXXXXXXXXXX in if itemList.present? loop XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
					p e
					Error.create(error:e,message:"vanilla-bean",url:url)
					p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
				end
			end
		rescue Exception => e
			p "XXXXXXXXXXXXXXXXXXXXXXX in siteurls each loop XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
			p e
			Error.create(error:e,message:"vanilla-bean")
			p "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
		end
	end

end
