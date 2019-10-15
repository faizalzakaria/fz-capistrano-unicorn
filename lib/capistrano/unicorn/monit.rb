module Capistrano
  class Unicorn::Monit < Capistrano::Plugin
    include UnicornCommon

    def register_hooks
      before 'deploy:updating', 'unicorn:monit:unmonitor'
      after 'deploy:published', 'unicorn:monit:monitor'
    end

    def define_tasks
      eval_rakefile File.expand_path('../../tasks/monit.rake', __FILE__)
    end

    def set_defaults
      set_if_empty :unicorn_monit_conf_dir, -> { "/etc/monit/conf.d/#{unicorn_monit_service_name}.conf" }
      set_if_empty :unicorn_monit_use_sudo, true
      set_if_empty :unicorn_monit_bin, '/usr/bin/monit'
    end

    def unicorn_monit_service_name
      fetch(:unicorn_monit_service_name, "unicorn_#{fetch(:application)}_#{fetch(:stage)}")
    end

    def sudo_if_needed(command)
      if fetch(:unicorn_monit_use_sudo)
        backend.sudo command
      else
        unicorn_role = fetch(:unicorn_role)
        backend.on(unicorn_role) do
          backend.execute command
        end
      end
    end
  end
end
