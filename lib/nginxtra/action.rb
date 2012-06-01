module Nginxtra
  module Action
    def initialize(thor, config, options = {})
      @thor = thor
      @config = config
      @options = options
    end

    # Run a daemon command to start or stop the nginx process.
    def daemon(action, additional_options = nil)
      action = "#{action} #{additional_options}" if additional_options
      @thor.run "#{sudo}start-stop-daemon --#{action} --quiet --pidfile #{Nginxtra::Config.nginx_pidfile} --exec #{Nginxtra::Config.nginx_executable}"
    end

    private
    def sudo(force = false)
      "sudo " if (force || @config.require_root?) && Process.uid != 0
    end
  end
end