# Implements Tasks spec defined at: 
# http://wiki.sproutcore.com/Todos+06-Building+the+Backend

require 'sinatra'
require 'dm-core'
require 'json'

require 'static'

# Define the data model

DataMapper.setup(:default, ENV['DATABASE_URL'] || 
    "sqlite3://#{File.join(File.dirname(__FILE__), 'tmp', 'tasks.db')}")

class Task 
  include DataMapper::Resource
  
  property :id,          Serial
  property :description, Text, :nullable => false
  property :is_done,     Boolean
  
  def url
    "/tasks/#{self.id}"
  end
  
  def to_json(*a)
    { 
      'guid'        => self.url, 
      'description' => self.description,
      'isDone'      => self.is_done 
    }.to_json(*a)
  end

  # keys that MUST be found in the json
  REQUIRED = [:description, :is_done]
  
  # ensure json is safe.  If invalid json is received returns nil
  def self.parse_json(body)
    json = JSON.parse(body)
    ret = { :description => json['description'], :is_done => json['isDone'] }
    return nil if REQUIRED.find { |r| ret[r].nil? }

    ret 
  end
  
end

DataMapper.auto_upgrade!


# return list of all installed tasks
get '/tasks' do
  content_type 'application/json'
  { 'content' => Array(Task.all) }.to_json
end

# create a new task.  request body to contain json
post '/tasks' do
  opts = Task.parse_json(request.body.read) rescue nil
  halt(401, 'Invalid Format') if opts.nil?
  
  task = Task.new(opts)
  task.save!

  response['Location'] = task.url
  response.status = 201
end

# Get an individual task
get "/tasks/:id" do
  task = Task.get(params[:id]) rescue nil
  halt(404, 'Not Found') if task.nil?

  content_type 'application/json'
  { 'content' => task }.to_json
end

# Update an individual task
put "/tasks/:id" do
  task = Task.get(params[:id]) rescue nil
  halt(404, 'Not Found') if task.nil?
  
  opts = Task.parse_json(request.body.read) rescue nil
  halt(401, 'Invalid Format') if opts.nil?
  
  task.update!(opts)
  response['Content-Type'] = 'application/json'
  { 'content' => task }.to_json
end

# Delete an invidual task
delete '/tasks/:id' do
  task = Task.get(params[:id]) rescue nil
  task.destroy unless task.nil?
end

  