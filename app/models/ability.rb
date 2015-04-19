class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    #

    # user ||= User.new # guest user (not logged in)
    # cannot :manage, :all # まず全権限を無しに
    # can :read, ActiveAdmin::Page, :name => "Dashboard" # for test, Dashboardは読める

    # if user.role.id = 1 then # for developer
    #   can :manage, :all
    # end
    # if user.role.id = 2 then # for manager
    #   can :read, ActiveAdmin::Page, :name => "User"
    # end
    # if user.role.id = 3 then # for user
    #   can :read, :all
    #   # can :read, ActiveAdmin::Page, :name => "User"
    # end

    user ||= User.new # guest user (not logged in)

    if user.role_id == 1 then # for developer
      can :manage, :all
    end
    if user.role_id == 3 then # for user
      can :read, :all
    end

  end

end
