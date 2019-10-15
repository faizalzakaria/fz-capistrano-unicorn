git_plugin = self

namespace :unicorn do
  desc 'Setup Unicorn config file'
  task :config do
    on roles(fetch(:unicorn_role)) do |role|
      git_plugin.upload_unicorn_rb(role)
    end
  end

  task :check do
    on roles(fetch(:unicorn_role)) do |role|
      unless  test "[ -f #{fetch(:unicorn_conf)} ]"
        warn 'unicorn.rb NOT FOUND!'
        git_plugin.upload_unicorn_rb(role)
        info 'unicorn.rb generated'
      end
    end
  end
end
