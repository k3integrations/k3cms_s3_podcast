module K3cms
  module S3Podcast
    class EpisodesController < K3cms::S3Podcast::BaseController
      before_filter :adjust_params
      # otherwise the load_resource :episode results in a 'Failed Authorization' error
      def adjust_params
        if params[:k3cms_s3_podcast_podcast_id]
          params[:podcast_id] = params[:k3cms_s3_podcast_podcast_id]
        end
      end

      load_resource :podcast, :class => 'K3cms::S3Podcast::Podcast'
      load_resource :episode, :class => 'K3cms::S3Podcast::Episode', :through => :podcast, :shallow => true

      def index
        @podcast or raise "podcast must be specified in the url (use the nested route, k3cms_s3_podcast_podcast_episodes_path(podcast))"

        if request.fullpath =~ /.rss$/
          @episodes = Episode.most_recent.limit(20)
        else
          @episodes = @episodes.order('id desc')
        end

        if params[:tag_list]
          @episodes = @episodes.tagged_with(params[:tag_list])
        end

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml  => @episodes }
          format.json { render :json => @episodes }
          format.rss
        end
      end

      def show
        respond_to do |format|
          if request.xhr?
            format.html {
              style = params[:style]
              style = 'tile' if style == 'tiles'
              render :text => render_cell('k3cms/s3_podcast/episodes_index', Rails.application.config.k3cms_s3_index_view, :episode => @episode, :podcast => @podcast, :style => style)
            }
          else
            format.html # show.html.erb
          end
          format.js # not currently used
          format.json {
            # So we have data-object="k3cms_s3_podcast_episode" so that the params come in as params[:k3cms_s3_podcast_episode] like the controller expects (and which works well since form_for @episode creates fields named that way).
            # But that causes it to expect the json object to be in the form {"k3cms_s3_podcast_episode":...}
            # But K3cms::S3Podcast::Episode.model_name.element drops the namespace and returns 'episode' by default. Here is my workaround:
            K3cms::S3Podcast::Episode.model_name.instance_variable_set('@element', dom_class(@episode))
            render :json => @episode
          }
          format.xml  { render :xml  => @episode }
        end
      end

      def new
        # TODO: duplicated with EpisodesCell
        @episode = K3cms::S3Podcast::Episode.new.set_defaults
        @episode.podcast = @podcast

        respond_to do |format|
          if request.xhr?
            format.html {
              style = params[:style]
              style = 'tile' if style == 'tiles'
              render :text => render_cell('k3cms/s3_podcast/episodes_index', Rails.application.config.k3cms_s3_show_view, :episode => @episode, :podcast => @podcast, :style => style)
            }
          else
            format.html # new.html.erb
          end
          format.xml  { render :xml  => @episode }
          format.json { render :json => @episode }
        end
      end

      def create
        @episode.attributes = params[:k3cms_s3_podcast_episode]
        @episode.author = current_user

        respond_to do |format|
          if @episode.save
            format.html do
              redirect_to(k3cms_s3_podcast_episode_url(@episode, :focus => ".editable[data-object-id=#{dom_id(@episode)}][data-attribute=title]:visible"),
                          :notice => 'Episode was successfully created.')
            end
            format.json { redirect_to(k3cms_s3_podcast_episode_url(@episode)) }
            format.xml  { render :xml => @episode, :status => :created, :location => @episode }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
            format.json { render :json => {:error => @episode.errors.full_messages.join('<br/>')} }
          end
        end
      end

      def edit
      end

      def update
        respond_to do |format|
          if @episode.update_attributes(params[:k3cms_s3_podcast_episode])
            format.html { redirect_to(k3cms_s3_podcast_episode_url(@episode), :notice => 'Episode was successfully updated.') }
            format.xml  { head :ok }
            format.json { render :json => {} }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
            format.json { render :json => {:error => @episode.errors.full_messages.join('<br/>')} }
          end
        end
      end

      def destroy
        @episode.destroy
        respond_to do |format|
          format.html { redirect_to(k3cms_s3_podcast_podcast_episodes_url(@episode.podcast)) }
          format.js
          format.xml  { head :ok }
          format.json { render :nothing =>  true }
        end
      end

    end
  end
end
