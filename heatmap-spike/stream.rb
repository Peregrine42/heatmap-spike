require 'json'
require 'sinatra'

set :public_folder, Proc.new { File.join(root, "public") }
set server: 'thin'

get '/' do
  erb :index
end

get '/admin' do
  erb :admin
end

def timestamp
  Time.now.strftime("%H:%M:%S")
end

def current_state
  {
    'timestamp' => timestamp,
    'events' => [
      { 'target' => 'cumbria', 'value' => '0.4' },
      { 'target' => 'caerphilly', 'value' => '-0.2' },
      { 'target' => 'nottinghamshire', 'value' => '0.9' }
    ]
  }.to_json
end

connections = []

get '/connect', provides: 'text/event-stream' do
  stream :keep_open do |out|
    connections << out

    puts connections

    out.callback {
      connections.delete(out)
    }
  end
end

get '/initial', provides: 'text' do
  current_state
end

post '/push' do
  puts params

  message = {
    'timestamp' => timestamp,
    'events' => [
      params
    ]
  }

  connections.each { |out| out << "data: #{message.to_json}\n\n" }
end
