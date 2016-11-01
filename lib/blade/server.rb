require "faye/websocket"
require "useragent"

module Blade::Server
  extend self
  include Blade::Component

  WEBSOCKET_PATH = "/blade/websocket"

  def start
    Faye::WebSocket.load_adapter("puma")
    server = Puma::Server.new(app)
    server.add_tcp_listener(host, Blade.config.port)
    server.run
  end

  def host
    Puma::Const::LOCALHOST
  end

  def websocket_url(path = "")
    Blade.url(WEBSOCKET_PATH + path)
  end

  def client
    @client ||= Faye::Client.new(websocket_url)
  end

  def subscribe(channel)
    client.subscribe(channel) do |message|
      yield message.with_indifferent_access
    end
  end

  def publish(channel, message)
    client.publish(channel, message)
  end

  private
    def app
      Rack::Builder.app do
        use Rack::ShowExceptions
        run Blade::RackAdapter.new
      end
    end
end
