class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  before_filter :set_wishlist_variable
  before_filter :set_contact_variable


  def set_wishlist_variable
    @create_new_wishlist = Wishlist.new
  end

  def set_contact_variable
    @contact = Contact.new
  end

  protected

    def configure_devise_permitted_parameters
      registration_params = [:email, :password, :wishlist_id, :threshold]

      if params[:action] == 'update'
        devise_parameter_sanitizer.for(:account_update) {
          |u| u.permit(registration_params << :current_password)
        }
      elsif params[:action] == 'create'
        devise_parameter_sanitizer.for(:sign_up) {
          |u| u.permit(registration_params)
        }
      end
    end
end
