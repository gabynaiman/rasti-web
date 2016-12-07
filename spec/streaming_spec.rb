require 'minitest_helper'

describe 'Straming' do

  let(:request) { Rack::Request.new Hash.new }
  let(:response) { Rack::Response.new }
  let(:render) { Rasti::Web::Render.new request, response }
  
  it 'Server sent events' do
    render.server_sent_events :channel_1

    response.status.must_equal 200
    response['Content-Type'].must_equal 'text/event-stream'
    response['Cache-Control'].must_equal 'no-cache'
    response['Connection'].must_equal 'keep-alive'
    response.body.must_be_instance_of Rasti::Web::Stream

    events = []
    thread = Thread.new do
      response.body.each { |e| events << e }
    end

    channel_1 = Rasti::Web::Channel[:channel_1]
    channel_2 = Rasti::Web::Channel[:channel_2]
    sleep 0.05 # Wait for establish connection

    3.times do |i|
      data = {text: "Tick #{i}"}
      event = Rasti::Web::ServerSentEvent.new data, id: i, event: 'tick'
      channel_1.publish event
      channel_2.publish event
    end

    Timeout.timeout(3) do
      while events.count < 3; 
        sleep 0.0001 # Wait for subscriptions
      end
    end
    
    response.body.close 

    events.must_equal 3.times.map { |i| "id: #{i}\nevent: tick\ndata: {\"text\":\"Tick #{i}\"}\n\n" }
  end

end