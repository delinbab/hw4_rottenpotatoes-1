class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  def self.with_same_director director_name
    Movie.where(:director => director_name)
  end
end
