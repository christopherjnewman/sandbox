class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully!"
      sign_in authentication.user
      redirect_to authentication.user
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new :name => omniauth['info']['name'], :bio => omniauth['info']['description']
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Authentication successful."
        sign_in user
        redirect_to user
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication"
    redirect_to authentications_url
  end

end
