module K3cms
  module S3Podcast
    class Ability
      include CanCan::Ability

      def initialize(user)
        #----------------------------------------------------------------------------------------------------
        # Podcasts

        if user.k3cms_permitted?(:list_podcast)
          can :index, K3cms::S3Podcast::Podcast
        end

        if user.k3cms_permitted?(:view_podcast)
          can :read, K3cms::S3Podcast::Podcast
        end

        if user.k3cms_permitted?(:edit_podcast)
          can :read, K3cms::S3Podcast::Podcast
          can :update, K3cms::S3Podcast::Podcast
        end

        if user.k3cms_permitted?(:edit_own_podcast)
          can :read, K3cms::S3Podcast::Podcast
          can :update, K3cms::S3Podcast::Podcast, :author_id => user.id
        end

        if user.k3cms_permitted?(:create_podcast)
          can :create, K3cms::S3Podcast::Podcast
        end

        if user.k3cms_permitted?(:delete_podcast)
          can :destroy, K3cms::S3Podcast::Podcast
        end

        if user.k3cms_permitted?(:delete_own_podcast)
          can :destroy, K3cms::S3Podcast::Podcast, :author_id => user.id
        end

        #----------------------------------------------------------------------------------------------------
        # Episodes

        if user.k3cms_permitted?(:view_episode)
          can :read, K3cms::S3Podcast::Episode, [] do |episode|
            episode.published?
          end
        end

        if user.k3cms_permitted?(:edit_episode)
          can :read, K3cms::S3Podcast::Episode
          can :update, K3cms::S3Podcast::Episode
        end

        if user.k3cms_permitted?(:edit_own_episode)
          can :read, K3cms::S3Podcast::Episode
          can :update, K3cms::S3Podcast::Episode, :author_id => user.id
        end

        if user.k3cms_permitted?(:create_episode)
          can :create, K3cms::S3Podcast::Episode
        end

        if user.k3cms_permitted?(:delete_episode)
          can :destroy, K3cms::S3Podcast::Episode
        end

        if user.k3cms_permitted?(:delete_own_episode)
          can :destroy, K3cms::S3Podcast::Episode, :author_id => user.id
        end
      end
    end
  end
end
