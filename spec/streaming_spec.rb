require 'minitest_helper'

describe 'Straming' do

  let(:request) { Rack::Request.new Hash.new }
  let(:response) { Rack::Response.new }
  let(:render) { Rasti::Web::Render.new request, response }
  
  it 'Server sent events' do
    events = []
    stream = render.server_sent_events :test_channel

    thread = Thread.new do
      stream.each { |e| events << e }
    end

    3.times do |i|
      data = {text: "Tick #{i}"}
      event = Rasti::Web::ServerSentEvent.new data, id: i, event: 'tick'
      Rasti::Web::Channel[:test_channel].publish event
    end

    while events.count < 3; sleep 0.0001 end
    stream.close 

    events.must_equal 3.times.map { |i| "id: #{i}\nevent: tick\ndata: {\"text\":\"Tick #{i}\"}\n\n" }
  end

end