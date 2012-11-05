Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    match = Movie.where(:title => movie["title"], :rating => movie["rating"], :director => movie["director"], :release_date => movie["release_date"].to_datetime).first
    Movie.create(:title => movie["title"], :rating => movie["rating"], :director => movie["director"], :release_date => movie["release_date"].to_datetime) if !match
  end
end


Then /the director of "(.*)" should be "(.*)"/ do |movie_name, director|
  Movie.find_by_title(movie_name).director == director ? true : raise("director is not the same")
end
