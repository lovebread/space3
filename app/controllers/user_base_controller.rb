class UserBaseController < ApplicationController

  before_filter :login_required

  before_filter :setup_instant_messenger

  before_filter :setup

protected

  def user_game_conds
    {:game_id => current_user.characters.map(&:game_id).uniq}
  end
  
  def setup_instant_messenger
    @online_friends = current_user.online_friends
    @im_info = {}
    current_user.unread_messages.group_by(&:poster).each do |poster, messages|
      @im_info["#{poster.id}"] = {
        :login => poster.login, 
        :messages => messages.map{|m| {:content => m.content, :created_at => m.created_at, :id => m.id}}
      }
    end
  end

  def setup
    # override this method in child controller
  end

  def require_owner owner
    owner == current_user || render_privilege_denied
  end

  def require_none_owner owner
    owner != current_user || render_privilege_denied
  end

  def require_friend owner
    owner.relationship_with(current_user) == 'friend' || render_privilege_denied
  end

  def require_none_friend owner
    owner.relationship_with(current_user) != 'friend' || render_privilege_denied
  end

  def require_friend_or_owner owner
    relationship = owner.relationship_with current_user
    relationship == 'friend' || relationship == 'owner' || render_add_friend(owner)
  end

  def require_adequate_privilege resource
    resource.available_for? current_user || render_privilege_denied
  end

  def render_privilege_denied
    render :template => 'not_found'
  end

  def render_not_found
    render :template => 'not_found'
  end

  def render_add_friend friend
    redirect_to new_friend_url(:uid => friend.id) 
  end

end
