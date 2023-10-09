class UsersController < ApplicationController
  # def show
  #   @user = User.find(params[:id])
  # end
  def show
    user_cache_key = "user_#{params[:id]}"
    cached_user = Rails.cache.read(user_cache_key)
  
    if cached_user
      @user = cached_user
    else
      @user = User.find(params[:id])
      Rails.cache.write(user_cache_key, @user, expires_in: 1.hour)
    end
  end
  
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save 
      # Cache the user data
      log_in @user
      Rails.cache.write("user_#{params[:id]}", @user.to_json,expires_in: 1.minute)
      
      flash[:success] = 'Welcome to the sample App!'
      redirect_to user_url(@user)
    else
      render 'new'
    end
  end
  
  

  private 

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
end
