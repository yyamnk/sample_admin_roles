class UserDetailsController < InheritedResources::Base

  private

    def user_detail_params
      params.require(:user_detail).permit(:name_ja, :name_en, :department_id, :grade_id, :tel)
    end
end

