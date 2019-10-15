require 'capistrano/bundler'
require "capistrano/plugin"

module Capistrano
  module UnicornCommon
    def unicorn_user(role)
      properties = role.properties
      properties.fetch(:run_as) || # global property across multiple capistrano gems
        role.user
    end

    def template_unicorn(from, to, role)
      @role = role
      file = [
          "lib/capistrano/templates/#{from}.rb.erb",
          "lib/capistrano/templates/#{from}.rb",
          "lib/capistrano/templates/#{from}.erb",
          "config/deploy/templates/#{from}.rb.erb",
          "config/deploy/templates/#{from}.rb",
          "config/deploy/templates/#{from}.erb",
          File.expand_path("../templates/#{from}.erb", __FILE__),
          File.expand_path("../templates/#{from}.rb.erb", __FILE__)
      ].detect { |path| File.file?(path) }
      erb = File.read(file)
      backend.upload! StringIO.new(ERB.new(erb, nil, '-').result(binding)), to
    end
  end

  class Unicorn < Capistrano::Plugin
    include UnicornCommon

    def define_tasks
      eval_rakefile File.expand_path('../tasks/unicorn.rake', __FILE__)
    end

    def set_defaults
      set_if_empty :unicorn_role, :app
      set_if_empty :unicorn_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
      set_if_empty :unicorn_workers, 2
      set_if_empty :unicorn_timeout, 30
      set_if_empty :unicorn_pid, -> { File.join(shared_path, 'tmp', 'pids', 'unicorn.pid') }
      set_if_empty :unicorn_socket, -> { File.join(shared_path, 'tmp', 'sockets', 'unicorn.sock') }
      set_if_empty :unicorn_bind, -> { File.join("unix://#{shared_path}", 'tmp', 'sockets', 'unicorn.sock') }
      set_if_empty :unicorn_conf, -> { File.join(shared_path, 'unicorn.rb') }
      set_if_empty :unicorn_access_log, -> { File.join(shared_path, 'log', 'unicorn_access.log') }
      set_if_empty :unicorn_error_log, -> { File.join(shared_path, 'log', 'unicorn_error.log') }
      set_if_empty :unicorn_preload_app, false
    end

    def register_hooks
      after 'deploy:check', 'unicorn:check'
      after 'deploy:finished', 'unicorn:monit:restart'
    end

    def upload_unicorn_rb(role)
      template_unicorn 'unicorn', fetch(:unicorn_conf), role
    end
  end
end

require 'capistrano/unicorn/monit'
