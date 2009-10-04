# Serve up static assets with a long expiration header

get '/static/*' do
  
  # Get file path.  if refers to a directory, try index.html
  path = params[:splat].first.split('/')
  path = File.join(File.dirname(__FILE__), 'static', *path)
  path = File.join(path, 'index.html') if File.directory?(path)
    
  # set long expiration headers  
  one_year = 360 * 24 * 60 * 60 # a little less than a year for proxy's-sake
  time = Time.now + one_year
  time = time.to_time if time.respond_to?(:to_time)
  time = time.httpdate if time.respond_to?(:httpdate)

  response['Expires'] = time
  response['Cache-Control'] = "public, max-age=#{one_year}"
  
  # send actual file
  send_file(path)

end

# Serve up SC app as well - requires config written to config.ru
def send_app(app=nil, language=nil)
  app = DEFAULT_APP if app.nil?
  language = DEFAULT_LANGUAGE if language.nil?
  
  path = File.join(File.dirname(__FILE__), 'static', app, language, CURRENT_BUILDS[app], 'index.html')
  send_file(path)
end

get '/' do
  send_app
end

get "/#{DEFAULT_APP}/?" do
  send_app
end

get "/#{DEFAULT_APP}/:language/?" do
  send_app(DEFAULT_APP, params[:language])
end

