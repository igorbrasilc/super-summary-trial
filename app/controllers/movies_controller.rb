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
      
      rented_movie = RentEngine.new(user, movie).rent
      render json: rented_movie

    rescue ActiveRecord::RecordNotFound => e
      error_message = e.model == "User" ? "User not found" : "Movie not found"
      render json: { error: error_message }, status: :not_found
    rescue RentEngine::RentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end