require "test_helper"

class RentEngineTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "Igor")
    @movie = Movie.create!(
      title: "Batman",
      available_copies: 1
    )
  end

  test "successfully rents a movie" do
    engine = RentEngine.new(@user, @movie)
    rented_movie = engine.rent

    assert_equal @movie, rented_movie
    assert_includes @user.reload.rented, @movie
    assert_equal 0, @movie.reload.available_copies
  end

  test "raises error when movie is already rented" do
    @user.rented << @movie

    engine = RentEngine.new(@user, @movie)
    
    assert_raises(RentEngine::RentError, "User has already rented this movie") do
      engine.rent
    end
  end

  test "raises error when no copies available" do
    @movie.update!(available_copies: 0)
    engine = RentEngine.new(@user, @movie)
    
    assert_raises(RentEngine::RentError, "No copies available") do
      engine.rent
    end
  end

  test "transaction rolls back if any operation fails" do
    initial_copies = @movie.available_copies
    
    engine = RentEngine.new(@user, @movie)
    
    def engine.add_to_user_rentals
      raise StandardError
    end
    
    assert_raises(StandardError) { engine.rent }
    
    @movie.reload
    assert_equal initial_copies, @movie.available_copies
    assert_not_includes @user.reload.rented, @movie
  end
end 