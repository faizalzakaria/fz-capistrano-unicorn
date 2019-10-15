git_plugin = self

namespace :unicorn do
  namespace :monit do
    desc 'Config Unicorn monit-service'
    task :config do
      on roles(fetch(:unicorn_role)) do |role|
        git_plugin.template_unicorn 'unicorn_monit.conf', "#{fetch(:tmp_dir)}/unicorn_monit.conf", role
        git_plugin.sudo_if_needed "mv #{fetch(:tmp_dir)}/unicorn_monit.conf #{fetch(:unicorn_monit_conf_dir)}"
        git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} reload"
        # Wait for Monit to be reloaded
        sleep 1
      end
    end

    desc 'Monitor Unicorn monit-service'
    task :monitor do
      on roles(fetch(:unicorn_role)) do
        begin
          git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} monitor #{git_plugin.unicorn_monit_service_name}"
        rescue
          invoke 'unicorn:monit:config'
          git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} monitor #{git_plugin.unicorn_monit_service_name}"
        end
      end
    end

    desc 'Unmonitor Unicorn monit-service'
    task :unmonitor do
      on roles(fetch(:unicorn_role)) do
        begin
          git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} unmonitor #{git_plugin.unicorn_monit_service_name}"
        rescue
          # no worries here (still no monitoring)
        end
      end
    end

    desc 'Start Unicorn monit-service'
    task :start do
      on roles(fetch(:unicorn_role)) do
        git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} start #{git_plugin.unicorn_monit_service_name}"
      end
    end

    desc 'Stop Unicorn monit-service'
    task :stop do
      on roles(fetch(:unicorn_role)) do
        git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} stop #{git_plugin.unicorn_monit_service_name}"
      end
    end

    desc 'Restart Unicorn monit-service'
    task :restart do
      on roles(fetch(:unicorn_role)) do
        git_plugin.sudo_if_needed "#{fetch(:unicorn_monit_bin)} restart #{git_plugin.unicorn_monit_service_name}"
      end
    end
  end
end
