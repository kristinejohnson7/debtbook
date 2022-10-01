require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'sinatra/json'
require 'sinatra/cross_origin'

db = Sequel.connect('sqlite://dev.db')
db.run "DROP TABLE IF EXISTS messages"
db.create_table :messages do
  primary_key :id
  String :message, null: false
end

configure do
  enable :cross_origin
end

before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

options "*" do
  response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end

before do
  @json_body = if ["POST", "PATCH", "PUT"].include? request.request_method
    request.body.rewind
    JSON.parse(request.body.read)
  end
end

get '/' do
  messages = db[:messages]
  all_messages = messages.all
  return json(all_messages)
end

post '/addmessage' do
  array_of_messages = @json_body["messages"]
  inserted_messages = []
  messages = db[:messages]
  for message in array_of_messages do
    new_message = messages.returning(:id, :message).insert(message: message)
    inserted_messages.push(new_message)
  end 
  return json(inserted_messages)
end

put '/messages/:id' do
  message = @json_body["message"]
  id = params["id"]
  messages = db[:messages]
  updated_message = messages.returning(:id, :message).where(:id =>id).update(:message => message)
  return json(updated_message)
end