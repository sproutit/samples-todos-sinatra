# Some common tasks to prepare the app for deployment.

# Point to the Todos SproutCore app
TODOS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'apps', 'todos'))

puts TODOS_ROOT

# run a server
default :server

task :server do
  `rackup -R`
end

