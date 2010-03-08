class Blog < ActiveRecord::Base

  
  
  acts_as_friend_taggable :delete_conditions => lambda {|user, blog| blog.poster == user},
                          :create_conditions => lambda {|user, blog| blog.poster == user}

  acts_as_viewable :create_conditions => lambda {|user, blog| blog.poster != user}

	acts_as_diggable :create_conditions => lambda {|user, blog| !blog.is_owner_privilege? or blog.poster == user}

  acts_as_resource_feeds

  acts_as_shareable :default_title => lambda {|blog| blog.title}

  acts_as_list :order => 'created_at', :scope => 'poster_id', :conditions => {:draft => false}

  acts_as_privileged_resources :owner_field => :poster # 指明资源的拥有者的域是poster

  acts_as_commentable :order => 'created_at ASC',
                      :delete_conditions => lambda {|user, blog, comment| user == blog.poster || user == comment.poster}, 
                      :create_conditions => lambda {|user, blog| blog.available_for? user}

  # poster_id 和 game_id 一经创建无法修改
  attr_readonly :poster_id, :game_id

  validates_presence_of :title, :message => "不能为空"

  validates_size_of :title, :within => 1..100, :too_long => "最长100个字节", :too_short => "最短1个字节", :allow_nil => true

  validates_presence_of :poster_id, :message => "不能为空", :on => :create

  validates_presence_of :content, :message => "不能为空" 

  validates_size_of :content, :within => 1..10000, :too_long => "最长10000字节", :too_short => "最短1个字节", :allow_nil => true

  validates_inclusion_of :privilege, :in => [1, 2, 3, 4], :message => "只能是1,2,3,4中的一个"  

  validates_presence_of :game_id, :message => "不能为空", :on => :create

  validate_on_create :game_is_valid

protected

  def game_is_valid
    return if game_id.blank?
    errors.add('game_id', "不存在") unless Game.exists?(game_id)
    return if poster_id.blank?
    errors.add('game_id', "该用户没有这个游戏") unless poster.characters.map(&:game_id).include?(game_id)
  end

end
