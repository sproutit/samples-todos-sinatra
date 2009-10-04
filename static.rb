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
