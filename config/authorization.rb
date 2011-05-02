K3cms::S3Podcast::Engine.authorization.draw do
  # First define and describe some suggested permission sets.
  suggested_permission_set :default, 'Allows managers to create & edit all podcasts/episodes, and delete their own episodes'
  suggested_permission_set :user_creation, 'Allows users to create and manage their own podcasts/episodes'

  context :podcasts do
    ability :view, 'Can view a podcast'  # Creates :view_podcast ability
    ability :list, 'Can list podcasts'
    ability :edit, 'Can edit a podcast'
    ability :edit_own, 'Can edit only my podcasts'
    ability :create, 'Can create a new podcast'
    ability :delete, 'Can delete a podcast'
    ability :delete_own, 'Can delete only podcasts created by me'

    extend_suggested_permission_set :default do
      guest :has => [:view, :list]
      user :includes_role => :guest
      manager :has => [:create, :edit_own, :delete_own], :includes_role => :user
      admin :has => :all
    end

    extend_suggested_permission_set :user_creation do
      guest :has => [:view, :list]
      user :has => [:create, :edit_own, :delete_own], :includes_role => :guest
      manager :has => :all
      admin :has => :all
    end
  end

  context :episodes do
    ability :view, 'Can view a episode'  # Creates :view_episode ability
    ability :edit, 'Can edit a episode'
    ability :edit_own, 'Can edit only my episodes'
    ability :create, 'Can create a new episode'
    ability :delete, 'Can delete a episode'
    ability :delete_own, 'Can delete only episodes created by me'

    extend_suggested_permission_set :default do
      guest :has => :view
      user :includes_role => :guest
      manager :has => [:create, :edit_own, :delete_own], :includes_role => :user
      admin :has => :all
    end

    extend_suggested_permission_set :user_creation do
      guest :has => :view
      user :has => [:create, :edit_own, :delete_own], :includes_role => :guest
      manager :has => :all
      admin :has => :all
    end
  end
end
