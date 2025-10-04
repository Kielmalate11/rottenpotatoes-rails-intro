class Movie < ApplicationRecord
	def self.all_ratings
	  %w[G PG PG-13 R NC-17]
	end

	def self.with_ratings(ratings_list)
	  return all if ratings_list.blank?
	  where(rating: ratings_list)
	end
end
