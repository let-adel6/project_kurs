class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  def index
    if current_user.role == 'user'
      redirect_to root_path, alert: "Доступ запрещен." and return
    end
    @users = User.all # Получаем список всех пользователей
  end

  def update_role
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Роль пользователя успешно изменена."
    else
      redirect_to admin_users_path, alert: "Не удалось изменить роль пользователя."
    end
  end

  def block
    user = User.find(params[:id])
    user.update(blocked: true)
    redirect_to admin_users_path, notice: 'Пользователь успешно заблокирован.'
  end

  private

   def user_params
     params.require(:user).permit(:role)
   end
   def authorize_admin
    redirect_to root_path, alert: "Доступ запрещен." unless current_user.admin?
   end
end