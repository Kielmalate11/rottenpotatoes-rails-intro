class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    ratings_param = params[:ratings]
    sort_param = params[:sort_by]

    if (ratings_param.blank? && session[:ratings].present?) ||
       (sort_param.blank? && session[:sort_by].present?)
     redirect_to movies_path(
       ratings: (ratings_param || session[:ratings]),
       sort_by: (sort_param || session[:sort_by])
     ) and return
    end


    @ratings_to_show = 
      if ratings_param.present?
        ratings_param.keys
      elsif session[:ratings].present?
        session[:ratings].keys
      else
       @all_ratings
      end

    @sort_by = 
      if sort_param.present?
        sort_param
      elsif session[:sort_by].present?
        session[:sort_by]
      else
        nil
      end
    @sort_by = nil unless %w[title release_date].include?(@sort_by)

    session[:ratings] = @ratings_to_show.index_with { '1' }
    session[:sort_by] = @sort_by

    @movies = Movie.with_ratings(@ratings_to_show)
    @movies = @movies.order(@sort_by) if @sort_by.present?
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
