ArchivesSpace::Application.extend_aspace_routes(File.join(File.dirname(__FILE__), "routes.rb"))

Rails.application.config.before_initialize do
  module ArchivesSpace
    class Application < Rails::Application
      plugin_dir = File.expand_path("..", File.expand_path(File.dirname(__FILE__)))
      config.i18n.load_path += Dir[File.join(plugin_dir, 'locales', '**', '*.yml')]
    end
  end
end

Rails.application.config.after_initialize do
  class ResolverController < ApplicationController

    set_access_control :public => [:resolve_edit, :resolve_readonly, :resolve_top_containers]


    def resolve_top_containers
      if params.has_key? :uri
        resolver = Resolver.new(params[:uri])

        if params.has_key?(:autoselect_repo) && resolver.repository && resolver.repository != session[:repo]
          self.class.session_repo(session, resolver.repository)
          selected = JSONModel(:repository).find(session[:repo_id])
          flash[:success] = t("repository._frontend.messages.changed", repository_repo_code: selected.repo_code)
        end

        redirect_to(
          :controller => :top_containers,
          :action => :index,
          :collection_resource => { 'ref' => params[:uri] },
          :autosearch => true
        )
      else
        unauthorised_access
      end
    end
  end


  class TopContainersController < ApplicationController
    def index
      respond_to do |format|
        format.html {
          # If there was a previous top_container search, we prepopulate the form with the filled-in linkers and a search is executed in top_containers.bulk.js
          @top_container_previous_search = {}

          if session[:top_container_previous_search] && session[:top_container_previous_search] != {}
            if session[:top_container_previous_search]['resource']
              @top_container_previous_search['resource'] = session[:top_container_previous_search]['resource']
              @top_container_previous_search['resource']['id'] = @top_container_previous_search['resource']['uri']
            end

            if session[:top_container_previous_search]['accession']
              @top_container_previous_search['accession'] = session[:top_container_previous_search]['accession']
              @top_container_previous_search['accession']['id'] = @top_container_previous_search['accession']['uri']
            end

            if session[:top_container_previous_search]['container_profile']
              @top_container_previous_search['container_profile'] = session[:top_container_previous_search]['container_profile']
              @top_container_previous_search['container_profile']['id'] = @top_container_previous_search['container_profile']['uri']
            end

            if session[:top_container_previous_search]['location']
              @top_container_previous_search['location'] = session[:top_container_previous_search]['location']
              @top_container_previous_search['location']['id'] = @top_container_previous_search['location']['uri']
            end
          end

          # Resolve collection_resource[ref] so the resource linker can display
          # the selected resource when the index page is opened directly with
          # a resource URI.
          if params.dig('collection_resource', 'ref')
            resource = JSONModel(:resource).find_by_uri(params.dig('collection_resource', 'ref'))

            @top_container_previous_search['resource'] = {
              'uri' => resource.uri,
              'id' => resource.uri,
              'title' => resource.title,
              'jsonmodel_type' => 'resource'
            }
          end

          @search_data = Search.for_type(session[:repo_id], 'top_container',
                                        params_for_backend_search.merge('facet[]' => SearchResultData.TOP_CONTAINER_FACETS))
        }
        format.csv {
          params[:fields] -= %w[title context type indicator barcode]
          params[:fields] += %w[type_enum_s indicator_u_icusort barcode_u_sstr]
          params[:fields].prepend('collection_display_string_u_sstr', 'series_title_u_sstr')
          csv_response(
            "/repositories/#{session[:repo_id]}/search",
            prepare_search.merge('facet[]' => SearchResultData.TOP_CONTAINER_FACETS),
            "#{t('top_container._plural').downcase}."
          )
        }
      end
    end
  end
  #from commit 5db743a

  class DigitalObjectComponentsController < ApplicationController
    include HandleFileUpload
    include ApplicationHelper

    def create
      handle_crud_with_file_uploads(:instance => :digital_object_component,
                  :find_opts => find_opts,
                  :on_invalid => ->() { return render_aspace_partial :partial => "new_inline" },
                  :on_valid => ->(id) {
                    # Refetch the record to ensure all sub records are resolved
                    # (this object isn't marked as stale upon create like Archival Objects,
                    # so need to do it manually)
                    @digital_object_component = JSONModel(:digital_object_component).find(id, find_opts)
                    digital_object = @digital_object_component['digital_object']['_resolved']
                    parent = @digital_object_component['parent']? @digital_object_component['parent']['_resolved'] : false

                    flash[:success] = @digital_object_component.parent ?
                      t("digital_object_component._frontend.messages.created_with_parent", digital_object_component_display_string: clean_mixed_content(@digital_object_component.title), digital_object_title: clean_mixed_content(digital_object['title']), parent_display_string: clean_mixed_content(parent['title'])) :
                      t("digital_object_component._frontend.messages.created", digital_object_component_display_string: clean_mixed_content(@digital_object_component.title), digital_object_title: clean_mixed_content(digital_object['title']))

                    if @digital_object_component["is_slug_auto"] == false &&
                      @digital_object_component["slug"] == nil &&
                      params["digital_object_component"] &&
                      params["digital_object_component"]["is_slug_auto"] == "1"

                      flash[:warning] = t("slug.autogen_disabled")
                    end

                    render_aspace_partial :partial => "digital_object_components/edit_inline"
                  })
    end


    def update
      params['digital_object_component']['position'] = params['digital_object_component']['position'].to_i if params['digital_object_component']['position']

      @digital_object_component = JSONModel(:digital_object_component).find(params[:id], find_opts)
      digital_object = @digital_object_component['digital_object']['_resolved']
      parent = @digital_object_component['parent'] ? @digital_object_component['parent']['_resolved'] : false

      handle_crud_with_file_uploads(:instance => :digital_object_component,
                  :obj => @digital_object_component,
                  :on_invalid => ->() { return render_aspace_partial :partial => "edit_inline" },
                  :on_valid => ->(id) {

                    flash.now[:success] = parent ?
                      t("digital_object_component._frontend.messages.updated_with_parent", digital_object_component_display_string: clean_mixed_content(@digital_object_component.title)) :
                      t("digital_object_component._frontend.messages.updated", digital_object_component_display_string: clean_mixed_content(@digital_object_component.title))
                    if @digital_object_component["is_slug_auto"] == false &&
                      @digital_object_component["slug"] == nil &&
                      params["digital_object_component"] &&
                      params["digital_object_component"]["is_slug_auto"] == "1"

                      flash.now[:warning] = t("slug.autogen_disabled")
                    end

                    render_aspace_partial :partial => "edit_inline"
                  })
    end

  end
  #from commit 0ff3a67

end