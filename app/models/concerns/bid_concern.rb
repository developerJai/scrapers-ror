# frozen_string_literal: true
module BidConcern
  extend ActiveSupport::Concern

  included do
    def get_updated_bid
      agent = Mechanize.new
      agent.log = Logger.new "manifests.log"
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      agent.user_agent_alias = "Mac Safari"
      user = User.first

      uri = self.product_url
      # /html/body/div[1]/div[3]/div[3]/div[1]/div[2]/table/tbody/tr[2]/th
      product_page = agent.get(uri) unless uri == "Unknown"
      json_response = JSON.parse(page.content)
      puts "Scraping: #{self.product_url}"
      # https://hibid.com/api/v1/bid/list/84308069?eventid=265205
      if json_response["bids"]
        json_response["bids"][0].to_f
      else
        nil
      end
    end
  end
end
