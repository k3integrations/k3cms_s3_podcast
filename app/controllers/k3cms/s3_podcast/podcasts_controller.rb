module K3cms
  module S3Podcast
    class PodcastsController < K3cms::S3Podcast::BaseController
      load_and_authorize_resource :podcast, :class => 'K3cms::S3Podcast::Podcast'

      def index
        @podcasts = Podcast.order('created_at asc')

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml  => @podcasts }
          format.json { render :json => @podcasts }
        end
      end

      def show
        respond_to do |format|
          if request.xhr?
            format.html {
              render :text => render_cell('k3cms/s3_podcast/podcasts', :show, :podcast => @podcast)
            }
          else
            format.html # show.html.erb
          end
          format.json { render :json => @podcast }
          format.xml  { render :xml  => @podcast }
        end
      end

      def new
        # TODO: duplicated with PodcastsCell
        @podcast = K3cms::S3Podcast::Podcast.new.set_defaults

        respond_to do |format|
          if request.xhr?
            format.html {
              render :text => render_cell('k3cms/s3_podcast/podcasts', :show, :podcast => @podcast)
            }
          else
            format.html # new.html.erb
          end
          format.xml  { render :xml  => @podcast }
          format.json { render :json => @podcast }
        end
      end

      def create
        @podcast.attributes = params[:k3cms_s3_podcast_podcast]
        @podcast.author = current_user

        respond_to do |format|
          if @podcast.save
            format.html do
              redirect_to(k3cms_s3_podcast_podcast_url(@podcast, :focus => ".editable[data-object-id=#{dom_id(@podcast)}][data-attribute=title]:visible"),
                          :notice => 'Podcast was successfully created.')
            end
            format.xml  { render :xml => @podcast, :status => :created, :location => @podcast }
            format.json {
              redirect_to(k3cms_s3_podcast_podcast_url(@podcast))
              #render :json => @podcast
            }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
            format.json { render :json => {:error => @podcast.errors.full_messages.join('<br/>'), :status => :unprocessable_entity} }
          end
        end
      end

      def edit
      end

      def update
        respond_to do |format|
          if @podcast.update_attributes(params[:k3cms_s3_podcast_podcast])
            format.html { redirect_to(k3cms_s3_podcast_podcast_url(@podcast), :notice => 'Podcast was successfully updated.') }
            format.xml  { head :ok }
            format.json { render :json => {} }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
            format.json { render :json => {:error => @podcast.errors.full_messages.join('<br/>')}, :status => :unprocessable_entity }
          end
        end
      end

      def destroy
        @podcast.destroy
        respond_to do |format|
          format.html { redirect_to(k3cms_s3_podcast_podcasts_url) }
          format.js
          format.xml  { head :ok }
          format.json { render :nothing =>  true }
        end
      end

    end
  end
end
