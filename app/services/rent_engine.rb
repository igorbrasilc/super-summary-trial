class RentEngine
  def initialize(user, movie)
    @user = user
    @movie = movie
  end

  def rent
    raise RentError.new("User has already rented this movie") if already_rented?
    raise RentError.new("No copies available") unless copies_available?

    ActiveRecord::Base.transaction do
      decrease_available_copies
      add_to_user_rentals
    end
    
    @movie
  end

  private

  def already_rented?
    @user.rented.include?(@movie)
  end

  def copies_available?
    @movie.available_copies > 0
  end

  def decrease_available_copies
    @movie.update!(available_copies: @movie.available_copies - 1)
  end

  def add_to_user_rentals
    @user.rented << @movie
  end

  class RentError < StandardError; end
end
