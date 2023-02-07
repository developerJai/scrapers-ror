class TripAdvisorHtml < ApplicationRecord
  belongs_to :trip_advisor_main_page_html
  has_many :trip_advisor_items,dependent: :destroy

end
