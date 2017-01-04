require 'minitest_helper'

describe 'Straming' do

  let(:request) { Rack::Request.new Hash.new }
  let(:response) { Rack::Response.new }
  let(:render) { Rasti::Web::Render.new request, response }

  def wait_for(&block)
    Timeout.timeout(3) do
      while !block.call
        sleep 0.0001
      end
    end
  end
  
  it 'Server sent events' do
    render.server_sent_events :channel_1

    response.status.must_equal 200
    response['Content-Type'].must_equal 'text/event-stream'
    response['Cache-Control'].must_equal 'no-cache'
    response['Connection'].must_equal 'keep-alive'
    response.body.must_be_instance_of Rasti::Web::Stream

    events = []
    
    Thread.new do
      response.body.each { |e| events << e }
    end

    channel_1 = Rasti::Web::Channel[:channel_1]
    channel_2 = Rasti::Web::Channel[:channel_2]

    3.times do |i|
      data = {text: "Tick #{i}"}
      event = Rasti::Web::ServerSentEvent.new data, id: i, event: 'tick'
      channel_1.publish event
      channel_2.publish event
    end

    wait_for { events.count == 3 }
    
    response.body.close 

    events.must_equal 3.times.map { |i| "id: #{i}\nevent: tick\ndata: {\"text\":\"Tick #{i}\"}\n\n" }
  end

end