Rails.application.config.before_initialize do
  module ArchivesSpace
    class Application < Rails::Application
      plugin_dir = File.expand_path("..", File.expand_path(File.dirname(__FILE__)))
      config.i18n.load_path += Dir[File.join(plugin_dir, 'locales', '**', '*.yml')]
    end
  end
end

Rails.application.config.after_initialize do

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