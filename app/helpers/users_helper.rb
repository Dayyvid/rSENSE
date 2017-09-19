module UsersHelper
  def user_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'user', field: field, value: @user[field], row_id: @user.id,
      can_edit: can_edit, make_link: make_link, href: url
  end

    def enable_subscription
    @user = User.find(params[:id])
    @user.update_attribute(:subscribed, true)
    UserMailer.send_welcome_to(@user).deliver
    redirect_to :back
  end

  def disable_subscription

    @user = User.find(params[:id])
    @user.update_attribute(:subscribed, false)
    redirect_to :back
  end
end
