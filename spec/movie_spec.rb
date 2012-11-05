require 'spec_helper'
describe MoviesController, :type => :controller do 
  describe "same_director happy path" do
    it "should call the model method to perform search for same movies" do
      Movie.should_receive(:with_same_director).with("John Doe")
      fake_result = mock("movie", :director => "John Doe", :title => "fake title")
      Movie.stub(:find).and_return(fake_result)
      get :same_director, {:id => "fake_id"}
    end
    it "should assign movies list to @movies" do
      fake_result = mock("movie", :director => "John Doe", :title => "fake title")
      fake_result_2 = mock("movie", :director => "John Doe", :title => "another fake title")
      Movie.stub(:find).and_return(fake_result)
      Movie.stub(:with_same_director).and_return(fake_result_2)
      get :same_director, {:id => "fake_id"}
      assigns(:movies).should eq(fake_result_2)
    end
    it "should assign movie title to @movie_name" do
      fake_result = mock("movie", :director => "John Doe", :title => "fake title")
      fake_result_2 = mock("movie", :director => "John Doe", :title => "another fake title")
      Movie.stub(:find).and_return(fake_result)
      Movie.stub(:with_same_director).and_return(fake_result_2)
      get :same_director, {:id => "fake_id"}
      assigns(:movie_name).should eq(fake_result.title) 
    end
    it "should render 'same_director' view" do
      fake_result = mock("movie", :director => "John Doe", :title => "fake_title")
      fake_result_2 = mock("movie", :director => "John Doe", :title => "another fake title")
      Movie.stub(:find).and_return(fake_result) 
      Movie.stub(:with_same_director).and_return(fake_result_2)
      get :same_director, {:id => "fake_id"}
      response.should render_template('movies/same_director')
    end
  end
  describe "same director sad path" do
    it "should redirect to home page" do
      fake_result = mock("movie", :title => "fake title", :director => nil)
      Movie.stub(:find).and_return(fake_result)
      get :same_director, {:id => "fake_id"}
      response.should redirect_to(root_url)
    end
    it "sets a flash notice message" do
      fake_result = mock("movie", :title => "fake title", :director => nil)
      Movie.stub(:find).and_return(fake_result)
      get :same_director, {:id => "fake_id"}
      flash[:notice].should_not be_nil
    end
  end
  describe "same_director" do
    it "should call the model method 'find'" do
      created_movie = Movie.create(:title => "test title")
      Movie.should_receive(:find).with(created_movie.id)
      Movie.stub(:with_same_director).and_return("fake result")
      get :same_director, {:id => created_movie.id}
    end
  end
  describe "show" do
    it "should render 'show' view" do
      fake_result = mock("movie", :id => 1)
      Movie.stub(:find).and_return(fake_result)
      get :show, {:id => "fake_id"}
      response.should render_template('movies/show')
    end
    it "should assign the requested movie to @movie" do
      fake_result = mock("movie", :id => 1)
      Movie.stub(:find).and_return(fake_result)
      get :show, {:id => "fake_id"}
      assigns(:movie).should eq(fake_result)
    end
    it "should call the model method 'find'" do
      created_movie = Movie.create(:title => "test title")
      Movie.should_receive(:find).with(created_movie.id)
      get :show, {:id => created_movie.id}
    end
  end

  describe "update" do
    before do
      @movie = Movie.create(:title => "some title")
    end
  
    it "should find the movie and return the object" do
      put :update, { :id => @movie.id, :movie => { :title => "another title" } }
      response.should redirect_to(movie_path(@movie))
    end
  end

  describe "new" do
    it "should render 'new' view" do
      get :new
      response.should render_template('movies/new')
    end
  end
  describe "create" do
    it "should redirect to movies path" do
      movie = Movie.new(:title => "the title")
      post :create, {:movie => movie}
      response.should redirect_to(movies_path)
    end
    it "should set flash message" do
      movie = Movie.new(:title => "the title")
      post :create, {:movie => movie}
      flash[:notice].should_not be_nil
    end
  end
  describe "destroy" do
    it "should redirect to 'movies' view" do
      fake_movie = Movie.create(:title => "some fake title", :director => "a director")
      Movie.stub(:find).and_return(fake_movie)
      delete :destroy, {:id => fake_movie.id}
      response.should redirect_to(movies_path)
    end
    it "should set flash message" do
      fake_movie = Movie.create(:title => "some fake title", :director => "a director")
      Movie.stub(:find).and_return(fake_movie)
      delete :destroy, {:id => fake_movie.id}
      flash[:notice].should_not be_nil
    end
  end
  describe "edit" do
    it "should render 'edit' view" do
      fake_movie = mock("movie") 
      Movie.stub(:find).and_return(fake_movie)
      get :edit, {:id => "fake_id"}
      response.should render_template("movies/edit")
    end
  end
  describe "index" do
    it "should render 'index' view" do
      get :index
      response.should render_template("movies/index")
    end
    it "should assign variables @movies, @all_ratings" do
      fake_ratings = ["here", "are", "fake", "ratings"]
      fake_movies = mock("movie") 
      Movie.stub(:all_ratings).and_return(fake_ratings)
      Movie.stub(:find_all_by_rating).and_return(fake_movies)
      get :index
      assigns(:movies).should eq(fake_movies)
      assigns(:all_ratings).should eq(fake_ratings)
    end
    it "should make redirect if params[sort] != session[sort]" do
      session[:sort] = "title"
      get :index, {:sort => "release_date", :ratings => "PG-13"}
      response.should redirect_to(movies_path(:ratings => "PG-13", :sort => "release_date"))
    end
    it "should make redirect if params[ratings] != session[ratings]" do
      session[:ratings] = "PG-13"
      session[:sort] = "release_date"
      get :index, {:sort => "release_date", :ratings => "NC-17"}
      response.should redirect_to(movies_path(:ratings => "NC-17", :sort => "release_date"))
    end
  end
end
describe "MoviesHelper", :type => :helper do
  describe "oddness" do
    it "should return 'odd' for odd number" do
      helper.oddness(1).should eq("odd")
    end
    it "should return 'even' for even number" do
      helper.oddness(2).should eq("even")
    end
  end
end
describe Movie, :type => :model do
  describe "self.with_same_director" do
    it "should return movies with same director" do
      fake_result = mock("movie", :director => "John Doe")
      Movie.stub(:where).and_return(fake_result)
      Movie.with_same_director("fake_director_name").should == fake_result
    end
  end
end
