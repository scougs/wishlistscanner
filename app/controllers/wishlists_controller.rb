class WishlistsController < ApplicationController

  def index

  end


  def show
    @wishlist = Wishlist.find(params[:id])
    @wishlist_items = @wishlist.wishlist_show_items
  end


  def edit
    @wishlist = Wishlist.find(params[:id])
  end


  def update
    wishlist = Wishlist.find(params[:id])
    if wishlist.update_attributes(wishlist_params)
      redirect_to user_path, notice: 'Wishlist successfully updated'
    else
      render action: 'edit'
    end
  end


  def destroy
    @wishlist = Wishlist.find(params[:id])

    if @wishlist.destroy
      redirect_to dashboard_path(current_user), alert: 'Wishlist successfully deleted'
    else
      redirect_to dashboard_path(current_user), alert: 'Unable to remove wishlist'
    end
  end


  def create
    wishlist = current_user.wishlists.new(wishlist_params)
    if wishlist.save
      redirect_to dashboard_path(current_user), notice: 'Wishlist successfully created'
    else
      redirect_to dashboard_path(current_user), alert: 'Error creating wishlist'
    end

  end


  def new
    @wishlist = Wishlist.new
  end


  def run_scan
    wishlist = Wishlist.find(params[:id])
    wishlist.wishlist_run
    redirect_to dashboard_path(current_user), notice: 'Wishlist scan complete'
  end


  private

    def wishlist_params
      params.require(:wishlist).permit( :wishlist_id, :threshold, :wishlist_url, :last_scan_array, :last_scan_date )
    end

end
