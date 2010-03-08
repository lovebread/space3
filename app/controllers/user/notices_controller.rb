class User::NoticesController < UserBaseController

	def index
    @notices = current_user.notices
    render :action => 'index', :layout => 'app'
	end

	def first_ten
		@notices = current_user.notices.unread.find(:all, :limit => 10)
		render :partial => 'notices', :object => @notices
	end

	def read
    @notice.read_by current_user
		@notices = current_user.notices.unread.find(:all, :limit => 10)
		render :partial => 'notices', :object => @notices
	end

protected

	def setup
		if ["read"].include? params[:action] 
			@notice = Notice.find(params[:id])
      require_owner @notice.user
		end
	end

end
