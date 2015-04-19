class RegistrationsController < Devise::RegistrationsController

  protected

  def update_resource(resource, params)
    # super # 動作確認用, オーバーライドされたメソッドを読むのみ
    resource.update_without_current_password(params) # Userモデルで実装する
  end
end
