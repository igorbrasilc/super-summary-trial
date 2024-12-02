class RecommendationEngine
  def initialize(favorite_movies)
    @favorite_movies = favorite_movies
  end

  def recommendations
    genres = @favorite_movies.pluck(:genre)
    common_genres = genres.tally
                          .sort_by{ |_, count| -count }
                          .take(3)
                          .map(&:first)

    Movie.where(genre: common_genres)
        .order(rating: :desc)
        .limit(10)
  end
end