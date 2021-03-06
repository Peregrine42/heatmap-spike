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
      { 'id' => 'test1',
        'lon' => '-1.9079513987271581',
        'lat' => '52.48033691054388',
        'ping_rating' => '1',
        'packet_loss_rating' => '1'
      },
      { 'id' => 'test2',
        'lon' => '1.315464038567282',
        'lat' => '52.093199147268486',
        'ping_rating' => '0',
        'packet_loss_rating' => '0'
      },
      { 'id' => 'test3',
        'lon' => '-3.375123246720891',
        'lat' => '55.922959691995956',
        'ping_rating' => '0',
        'packet_loss_rating' => '1'
      },
      { 'id' => 'test4',
        'lon' => '-0.13896573405726872',
        'lat' => '51.521155548062815',
        'ping_rating' => '0.4',
        'packet_loss_rating' => '0.2'
      },
      { 'id' => 'test5',
        'lon' => '-2.2362957095513725',
        'lat' => '53.47771214497476',
        'ping_rating' => '0.5',
        'packet_loss_rating' => '0.1'
      }
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
  content_type :json
  { "done" => true }.to_json
end
