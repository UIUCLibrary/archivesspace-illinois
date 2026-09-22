ArchivesSpace::Application.routes.draw do
  [AppConfig[:frontend_proxy_prefix], AppConfig[:frontend_prefix]].uniq.each do |prefix|
    scope prefix do
      match('resolve/top_containers' => 'resolver#resolve_top_containers', :via => [:get])
    end
  end
end