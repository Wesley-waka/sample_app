class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update,:destroy]
  before_action :correct_user, only: [:edit, :update]
  befoe_action :admin_user, only: [:destroy]
  # def show
  #   @user = User.find(params[:id])
  # end

  def index
    @users = User.paginate(page: params[:page])
  end

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
  
  def edit
  end

  def update
    if @user.update_attributes(user_params)
      # handle a successful update
      flash[:success] = "Profile update"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:succes] = "User deleted"
    redirect_to users_url
    
  end

  private 

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  # Before filters
  
  # confirms a logged-in user
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms the correct user
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # confirms an admin user
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

end
