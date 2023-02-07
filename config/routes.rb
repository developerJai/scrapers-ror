Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "welcome#index"
  
  post "scraper/ebay" => "ebay_scrapers#create"
  post "scraper/vanilla_beans"=>"vanilla_scrapers#create"
  post "scraper/trip_advisor"=>"trip_advisor_scrapers#create"
  post "scraper/happycow" => "happycow_scrapers#create"
end
