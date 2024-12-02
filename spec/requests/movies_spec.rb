require 'swagger_helper'

RSpec.describe 'Movies API', type: :request, swagger_doc: 'v1/swagger.yaml' do

  @movie_properties = {
    id: { type: :integer },
    title: { type: :string },
    available_copies: { type: :integer },
    rating: { type: :number, format: :float },
    created_at: { type: :string, format: 'date-time' },
    updated_at: { type: :string, format: 'date-time' }
  }

  path '/movies' do

    get('List all movies') do
      tags ['Movie Catalog']
      description 'Retrieves all movies in the database'
      produces 'application/json'
      response(200, 'successful') do

        schema type: :array,
        items: {
          type: :object,
          properties: @movie_properties,
          required: ['id', 'title', 'available_copies', 'rating']
        }
        run_test!
      end
    end
  end

  path '/movies/recommendations' do

    get 'Get movie recommendations for a user' do
      tags ['Movie Recommendations']
      description 'Returns personalized movie recommendations based on user favorites'
      produces 'application/json'
      parameter name: :user_id, 
                in: :query, 
                type: :integer, 
                required: true,
                description: 'ID of the user to get recommendations for'

      response '200', 'recommendations found' do
        schema type: :array,
          items: {
            type: :object,
            properties: @movie_properties,
            required: ['id', 'title']
          }
        run_test!
      end
    end
  end

  path '/movies/user_rented_movies' do

    get 'Get movies rented by a user' do
      tags ['Movie Rentals']
      description 'Returns all movies currently rented by the specified user'
      produces 'application/json'
      parameter name: :user_id, 
                in: :query, 
                type: :integer, 
                required: true,
                description: 'ID of the user whose rentals to retrieve'

      response '200', 'rented movies found' do
        schema type: :array,
          items: {
            type: :object,
            properties: @movie_properties,
            required: ['id', 'title']
          }
        run_test!
      end
    end
  end

  path '/movies/{id}/rent' do
    get 'Rent a movie' do
      tags ['Movie Rentals']
      description 'Rents a movie for a specific user if copies are available'
      produces 'application/json'
      parameter name: :id, 
                in: :path, 
                type: :integer, 
                required: true,
                description: 'ID of the movie to rent'
      parameter name: :user_id, 
                in: :query, 
                type: :integer, 
                required: true,
                description: 'ID of the user renting the movie'

      response '200', 'movie rented successfully' do
        schema type: :object,
          properties: @movie_properties,
          required: ['id', 'title', 'available_copies']
        run_test!
      end
    end
  end
end
