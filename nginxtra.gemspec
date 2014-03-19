# Note: This gemspec generated by the Rakefile
require "rubygems/package_task"

Gem::Specification.new do |s|
  s.name           = "nginxtra"
  s.version        = "1.4.7.9"
  s.summary        = "Wrapper of nginx for easy install and use."
  s.description    = "This gem is intended to provide an easy to use configuration file that will automatically be used to compile nginx and configure the configuration."
  s.author         = "Mike Virata-Stone"
  s.email          = "reasonnumber@gmail.com"
  s.license        = "nginx"
  s.files          = FileList["bin/**/*", "lib/**/*", "templates/**/*", "vendor/**/*"]
  s.require_path   = "lib"
  s.bindir         = "bin"
  s.executables    = ["nginxtra", "nginxtra_rails"]
  s.homepage       = "https://github.com/mikestone/nginxtra"
  s.add_dependency "thor", "~> 0.16"
end
