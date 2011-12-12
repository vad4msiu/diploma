class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role? :admin
      can :manage, :all
    elsif user.role? :teacher
      can :read, Document
      can :manage, Report#, :user_id => user.id
    end
  end
end