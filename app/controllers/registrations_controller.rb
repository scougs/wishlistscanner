class RegistrationsController < Devise::RegistrationsController


  private

  def sign_up_params
    params.require(resource_name).permit( :email, :password )
  end

end

