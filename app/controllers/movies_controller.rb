class MoviesController < ApplicationController
  def index
    @movies = Movie.all
    render json: @movies
  end

  def recommendations
    begin  
      favorite_movies = User.find(params[:user_id]).favorites
      @recommendations = RecommendationEngine.new(favorite_movies).recommendations
      render json: @recommendations
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def user_rented_movies
    begin
      @rented = User.find(params[:user_id]).rented
      render json: @rented
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def rent
    begin
      user = User.find(params[:user_id])
      movie = Movie.find(params[:id])
      
      if movie.available_copies > 0 && !user.rented.include?(movie)
        movie.available_copies -= 1
        movie.save
        user.rented << movie
        render json: movie
      else
        error_message = if user.rented.include?(movie)
          "User has already rented this movie"
        else
          "No copies available"
        end
        render json: { error: error_message }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      error_message = e.model == "User" ? "User not found" : "Movie not found"
      render json: { error: error_message }, status: :not_found
    end
  end
end