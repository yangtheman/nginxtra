module Nginxtra
  module Actions
    # The Nginxtra::Actions::Install class encapsulates installing
    # nginxtra so that nginx can be started and stopped automatically
    # when the server is started or stopped.
    class Install
      include Nginxtra::Action

      # Run the installation of nginxtra.
      def install
        return up_to_date unless should_install?
        check_if_nginx_is_installed
        create_etc_script
        update_last_install
      end

      # Look for nginx installation and fail if it exists (unless
      # --ignore-nginx-check is passed).
      def check_if_nginx_is_installed
        return unless File.exists?("/etc/init.d/nginx")

        if @thor.options["ignore-nginx-check"]
          @thor.say @thor.set_color("Detected nginx install, but ignoring!", :red, true)
          return
        end

        raise Nginxtra::Error::NginxDetected.new("Uninstall nginx before installing nginxtra", :header => "It appears nginx is already installed!", :message => "Since /etc/init.d/nginx exists, you might have an existing nginx installation that will conflict with nginxtra.  If you want to install nginxtra alongside nginx (at your own risk), please include the --ignore-nginx-check option to bypass this check.")
      end

      # Create a script in the base directory which be symlinked to
      # /etc/init.d/nginxtra and then used to start and stop nginxtra
      # via update-rc.d.
      def create_etc_script
        filename = "etc.init.d.nginxtra"
        workingdir = File.expand_path "."

        @thor.inside Nginxtra::Config.base_dir do
          @thor.create_file filename, %{#!/bin/sh

### BEGIN INIT INFO
# Provides:          nginxtra
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts nginxtra, which is a wrapper around the nginx web server
# Description:       starts nginxtra which starts nginx using start-stop-daemon
### END INIT INFO

export GEM_HOME="#{ENV["GEM_HOME"]}"
export GEM_PATH="#{ENV["GEM_PATH"]}"
#{Nginxtra::Config.ruby_path} "#{File.join Nginxtra::Config.gem_dir, "bin/nginxtra"}" "$1" --basedir="#{Nginxtra::Config.base_dir}" --config="#{Nginxtra::Config.loaded_config_path}" --workingdir="#{workingdir}" --non-interactive
}, :force => true
          @thor.chmod filename, 0755
        end

        run! %{#{sudo true}rm /etc/init.d/nginxtra} if File.exists? "/etc/init.d/nginxtra"
        run! %{#{sudo true}ln -s "#{File.join Nginxtra::Config.base_dir, filename}" /etc/init.d/nginxtra}
        run! %{#{sudo true}update-rc.d nginxtra defaults}
      end

      # Notify the user that installation should be up to date.
      def up_to_date
        @thor.say "nginxtra installation is up to date"
      end

      # Mark the last installed version and last installed time (the
      # former being used to determine if nginxtra has been installed
      # yet).
      def update_last_install
        Nginxtra::Status[:last_install_version] = Nginxtra::Config.version
        Nginxtra::Status[:last_install_time] = Time.now
      end

      # Determine if the install should proceed.  This will be true if
      # the force option was used, or if this version of nginxtra
      # differs from the last version installed.
      def should_install?
        return true if force?
        Nginxtra::Status[:last_install_version] != Nginxtra::Config.version
      end
    end
  end
end
