require "test_helper"

class RecommendationEngineTest < ActiveSupport::TestCase
  setup do
    @movie1 = Movie.create!(title: "The Matrix", genre: "sci-fi", rating: 9.0)
    @movie2 = Movie.create!(title: "Inception", genre: "sci-fi", rating: 8.8)
    @movie3 = Movie.create!(title: "The Dark Knight", genre: "action", rating: 9.2)
    @movie4 = Movie.create!(title: "Interstellar", genre: "sci-fi", rating: 8.9)
    
    @favorite_movies = [@movie1, @movie2]
    @recommendation_engine = RecommendationEngine.new(@favorite_movies)
  end

  test "recommendations returns movies with similar genres" do
    recommendations = @recommendation_engine.recommendations
    
    assert_includes recommendations, @movie4 
    assert_equal 10, recommendations.limit_value
    assert_equal :desc, recommendations.order_values.first.direction  
  end

  test "recommendations prioritizes common genres" do
    recommendations = @recommendation_engine.recommendations
    
    sci_fi_count = recommendations.where(genre: "sci-fi").count
    action_count = recommendations.where(genre: "action").count
    
    assert sci_fi_count > action_count
  end

  test "get_movie_names returns array of movie titles" do
    titles = @recommendation_engine.send(:get_movie_names, @favorite_movies)
    
    assert_equal ["The Matrix", "Inception"], titles
    assert_kind_of Array, titles
  end
end