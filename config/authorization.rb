K3cms::S3Podcast::Engine.authorization.draw do
  # First define and describe some suggested permission sets.
  suggested_permission_set :default, 'Allows managers to create & edit all episodes, and delete their own episodes'
  suggested_permission_set :user_creation, 'Allows users to create and manage their own episodes'

  # Context makes all abilities defined within to be prefixed with the
  # singularized version of the given string.  Contexts can be nested.
  context :episodes do
    ability :view, 'Can view a episode'  # Creates :view_episode ability
    ability :edit, 'Can edit a episode'
    ability :edit_own, 'Can edit only my episodes'
    ability :create, 'Can create a new episode'
    ability :delete, 'Can delete a episode'
    ability :delete_own, 'Can delete only episodes created by me'

    # This defines the abilities for the default suggested permission set
    # in terms of the four default roles (guest, user, manager, admin)
    extend_suggested_permission_set :default do
      guest :has => :view
      # NOTE: :includes_role without first defining the role to be included
      # will cause an error.  The included abilities are limited to
      # this extend_suggested_permission_set block.
      user :includes_role => :guest
      manager :has => [:create, :edit_own, :delete_own], :includes_role => :user
      # :all only applies to the abilities in this context (:episodes)
      admin :has => :all
    end

    # Define abilities for the suggested permission set.
    extend_suggested_permission_set :user_creation do
      guest :has => :view
      user :has => [:create, :edit_own, :delete_own], :includes_role => :guest
      manager :has => :all
      admin :has => :all
    end
  end
end
