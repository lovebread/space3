class User::TagsController < UserBaseController

	def create
    unless @taggable.add_tag current_user, params[:tag_name]
      render :update do |page|
        page << "error('发生错误');"
      end
    end
	end

	def destroy
		if @taggable.destroy_tag @tag.name 
		  render :update do |page|
			  page << "$('tag_#{@tag.id}').remove();"
		  end
    else
      render :update do |page|
        page << "error('发生错误')"
      end
    end
	end

  def auto_complete_for_game_tags
    @tags = Tag.game_tags.search(params[:tag][:name])
    render :partial => 'game_tag_list'
  end

protected

	def setup
    if ["create"].include? params[:action]
      @taggable = get_taggable
		elsif ["destroy"].include? params[:action]
      @taggable = get_taggable
      require_delete_privilege @taggable
			@tag = Tag.find(params[:id])
		end
	end

  def require_delete_privilege taggable
    taggable.is_tag_deleteable_by? current_user || not_found
  end

end
