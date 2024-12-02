require "test_helper"

class MoviesFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Igor"
    )

    @another_user = User.create!(
        name: "Igor Cópia"
    )

    @movies = [
      Movie.create!(title: "The Matrix", genre: "sci-fi", rating: 9.0, available_copies: 2),
      Movie.create!(title: "Inception", genre: "sci-fi", rating: 8.8, available_copies: 1),
      Movie.create!(title: "The Dark Knight", genre: "action", rating: 9.2, available_copies: 3)
    ]

    @user.favorites << @movies[0..1]
  end

  test "can get index of all movies" do
    get movies_path
    
    assert_response :success
    movies = JSON.parse(@response.body)
    assert_equal @movies.count, movies.length
  end

  test "can get recommendations" do
    get recommendations_movies_path(user_id: @user.id)
    
    assert_response :success
    recommendations = JSON.parse(@response.body)
    assert_kind_of Array, recommendations
  end

  test "can get user rented movies" do
    @user.rented << @movies.first
    
    get user_rented_movies_movies_path(user_id: @user.id)
    
    assert_response :success
    rented_movies = JSON.parse(@response.body)
    assert_includes rented_movies.map { |m| m["title"] }, @movies.first.title
  end

  test "can rent a movie" do
    movie = @movies.last
    initial_copies = movie.available_copies
    
    post rent_movie_path(id: movie.id, user_id: @user.id)
    
    assert_response :success
    movie.reload
    assert_equal initial_copies - 1, movie.available_copies
    assert_includes @user.reload.rented, movie
  end

  test "cannot rent movie with no copies" do
    movie = @movies.second
    
    post rent_movie_path(id: movie.id, user_id: @user.id)
    assert_response :success
    
    post rent_movie_path(id: movie.id, user_id: @another_user.id)
    assert_response :unprocessable_entity
  end

  test "same user cannot rent the same movie without returning it" do
    movie = @movies.second

    post rent_movie_path(id: movie.id, user_id: @user.id)
    assert_response :success

    post rent_movie_path(id: movie.id, user_id: @user.id)
    assert_response :unprocessable_entity
  end
end
