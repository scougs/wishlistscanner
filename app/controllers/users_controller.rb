class UsersController < ApplicationController

  def index
    if current_user
      redirect_to dashboard_path(current_user)
    else
      render page_path('home')
    end
  end


  def dashboard
    @new_wishlist = Wishlist.new
    @contact = Contact.new
  end


  def show
    @user = User.find(params[:id])
  end


  def edit
    @user = User.find(params[:id])
  end


  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      redirect_to user_path, notice: 'User successfully updated'
    else
      render action: 'edit'
    end
  end


  def destroy

  end


  def create
    User.create(user_params)
  end


  def new
    @user = User.new
  end


  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :remember_me)
    end

end
