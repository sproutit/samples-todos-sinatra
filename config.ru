# Configure Sinatra as a Rack app
DEFAULT_APP = 'todos'
DEFAULT_LANGUAGE = 'en'
CURRENT_BUILDS = {
  'todos' => 'ee972277c11ed2d7cf0765e9c5b9738575b9248d'
}

require 'tasks'

run Sinatra::Application
