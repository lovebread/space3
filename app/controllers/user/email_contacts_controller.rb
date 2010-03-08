class User::EmailContactsController < UserBaseController

  rescue_from Contacts::TypeNotFound, :with => :render_not_supported

  rescue_from Contacts::AuthenticationError, :with => :render_authentication_error

  rescue_from Contacts::ConnectionError, :with => :render_connection_error

  def unregistered
    # read it from session??
    @contacts = Contacts.new(params[:type], params[:user_name], session[:email_authentication][:password]).contacts
    parse_contacts
    render :update do |page|
      page.replace_html 'contacts', :partial => 'unregistered'
    end
  end

  def not_friend
    @contacts = Contacts.new(params[:type], params[:user_name], session[:email_authentication][:password]).contacts
    parse_contacts
    session[:contacts] = @contacts
    if @not_friend_contacts.size != 0
      render :update do |page|
        page.replace_html 'contacts', :partial => 'not_friend'
      end
    else
      render :update do |page|
        page.redirect_to :controller => 'user/signup_invitations', :action => 'invite_contact'
      end
    end
  end

protected

  def render_not_supported e
    render :update do |page|
      flash[:notice] = "不支持的邮件类型"
      page.redirect_to signup_invitations_url
    end
  end

  def render_authentication_error e
    render :update do |page|
      flash[:notice] = "用户名或者密码错误"
      page.redirect_to signup_invitations_url
    end
  end

  def render_connection_error e
    render :update do |page|
      flash[:notice] = "连接错误,无法获得联系人"
      page.redirect_to signup_invitations_url
    end
  end

  def parse_contacts
    @registered_contacts = []
    @unregistered_contacts = []
    @friend_contacts = []
    @not_friend_contacts = []

    @contacts.each do |c|
      h = {:nickname => c[0], :email => c[1]}
      user = User.find_by_email(c[1])
      if user.blank?
        @unregistered_contacts << h
      else
        h[:user_id] = user.id
        @registered_contacts << h
        if current_user.has_friend? user
          @friend_contacts << h
        else
          @not_friend_contacts << h
        end
      end
    end
  end

end
