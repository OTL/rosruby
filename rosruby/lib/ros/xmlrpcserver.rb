# ros/xmlrpcserver.rb
#
# License: BSD
#
# Copyright (C) 2012 Takashi Ogura <t.ogura@gmail.com>
#
#

#

require 'xmlrpc/server'

module ROS

  # original XMLRPC Server (remove access log)
  class XMLRPCServer < XMLRPC::WEBrickServlet
    def initialize(port=8080,
                   host="127.0.0.1",
                   maxConnections=100,
                   stdlog="#{ENV['HOME']}/.ros/log/rosruby.log")
      super({})
      require 'webrick'
      FileUtils.mkdir_p(File.dirname(stdlog))
      @server = WEBrick::HTTPServer.new(:Port => port,
                                        :BindAddress => host,
                                        :MaxClients => maxConnections,
                                        :Logger => WEBrick::Log.new(stdlog),
                                        :AccessLog => [])
      @server.mount("/", self)
    end

    def serve
      @server.start
    end

    def shutdown
      @server.shutdown
    end
  end
end
