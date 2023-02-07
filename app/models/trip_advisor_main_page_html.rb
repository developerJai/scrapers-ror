class TripAdvisorMainPageHtml < ApplicationRecord
	has_many :trip_advisor_htmls,dependent: :destroy
end
