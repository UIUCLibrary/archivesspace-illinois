Rails.application.config.before_initialize do
  module ArchivesSpacePublic
    class Application < Rails::Application
      plugin_dir = File.expand_path("..", File.expand_path(File.dirname(__FILE__)))
      config.i18n.load_path += Dir[File.join(plugin_dir, 'locales', '**', '*.yml')]
    end
  end
end