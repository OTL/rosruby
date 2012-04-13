require 'xmlrpc/server'
require 'xmlrpc/client'
require 'timeout'

module ROS

  class TopicManager

    MAX_CONNECTION = 100

    attr_reader :publishers, :subscribers, :service_servers, :host, :port

    def initialize(caller_id, node)
      @caller_id = caller_id
      @node = node
      @host = node.host
      @port = get_available_port
      @master = XMLRPC::Client.new2(@node.master_uri).proxy
      @server = XMLRPC::Server.new(@port, @host, MAX_CONNECTION, $stderr, false, false)
      @publishers = []
      @subscribers = []
      @service_servers = []
      @server.set_default_handler do |method, *args|
        p 'call!! unhandled'
        p method
        p args
        [0, "I DON'T KNOW", 0]
      end

      @server.add_handler('getBusStats') do |caller_id|
        pubstats = @publishers.map do |pub|
          [pub.topic_name, pub.topic_type.type, pub.get_connection_data]
        end
        substats = @subscribers.map do |sub|
          [sub.topic_name, sub.get_connection_data]
        end
        servstats = @service_servers.map do |service|
          [service.get_connection_data]
        end
        [1, "stats", [pubstats, substats, servstats]]
      end

      @server.add_handler('getMasterUri') do |caller_id|
        [1, "master", @node.master_uri]
      end

      @server.add_handler('getSubscriptions') do |caller_id|
        @subscribers.map do |sub|
          [sub.topic_name, sub.topic_type.type]
        end
      end

      @server.add_handler('getPublications') do |caller_id|
        @publishers.map do |pub|
          [pub.topic_name, pub.topic_type.type]
        end
      end

      @server.add_handler('requestTopic') do |caller_id, topic, protocols|
        message = [0, "I DON'T KNOW", 0]
        protocols.select {|x| x[0] == 'TCPROS'}.each do |protocol|
          @publishers.select {|pub| pub.topic_name == topic}.each do |publisher|
            connection = publisher.add_connection(caller_id)
            message = [1, "OK! WAIT!!!", ['TCPROS',
                                          connection.host,
                                          connection.port]]
          end
        end
        message
      end

      @server.add_handler('shutdown') do |caller_id, msg|
        puts "shutting down by master request: #{msg}"
        @node.shutdown
        [1, 'shutdown ok', 0]
      end

      @server.add_handler('getPid') do |caller_id|
        [1, "pid ok", Process.pid]
      end

      @server.add_handler('getBusInfo') do |caller_id|
        info = []
        @publishers.each do |publisher|
          info.concat(publisher.get_connection_info)
        end
        @subscribers.each do |subscriber|
          info.concat(subscriber.get_connection_info)
        end
        [1, "getBusInfo ok", info]
      end

      @server.add_handler('publisherUpdate') do |caller_id, topic, publishers|
        @subscribers.select {|sub| sub.topic_name == topic}.each do |sub|
          publishers.select {|uri| not sub.has_connection_with?(uri)}.each do |uri|
            sub.add_connection(uri)
          end
          sub.get_connected_uri.select {|uri| not publishers.include?(uri)}.each do |uri|
            sub.drop_connection(uri)
          end
        end
        [1, "OK! Updated!!", 0]
      end

      @thread = Thread.new do
        @server.serve
      end
      
    end


    def get_available_port
      server = TCPServer.open(0)
      saddr = server.getsockname
      port = Socket.unpack_sockaddr_in(saddr)[0]
      server.close
      port
    end

    def get_uri
      "http://" + @host + ":" + @port.to_s + "/"
    end

    def wait_for_service(service_name, timeout_sec)
      begin
        timeout(timeout_sec) do
          while @node.ok?
            code, message, uri = @master.lookupService(@caller_id,
                                                       service_name)
            if code == 1
              return true
            end
            sleep(0.1)
          end
        end
      rescue Timeout::Error
        puts "time outed for wait service #{service_name}"
        return nil
      rescue
        raise "connection with master failed. master = #{@node.master_uri}"
      end
    end

    def add_service_server(service_server)
      code, message, val = @master.registerService(@caller_id,
                                                   service_server.service_name,
                                                   service_server.service_uri,
                                                   get_uri)
      if code == 1
        @service_servers.push(service_server)
      else
        raise 'registerService fail: #{message}'
      end

    end

    def unregister_service_server(service)
      code, message, val = @master.unregisterService(@caller_id,
                                                     service.service_name,
                                                     service.service_uri)
      if code == 1
        return service
      else
        raise "unregisterService fail: #{message}"
      end
    end

    def add_subscriber(subscriber)
      code, message, uris = @master.registerSubscriber(@caller_id,
                                                       subscriber.topic_name,
                                                       subscriber.topic_type.type,
                                                       get_uri)
      if code == 1
        uris.each do |publisher_uri|
          subscriber.add_connection(publisher_uri)
        end
        @subscribers.push(subscriber)
        return subscriber
      else
        raise "registration of publisher failed"
      end
    end

    def unregister_subscriber(subscriber)
      code, message,val = @master.unregisterSubscriber(@caller_id,
                                                       subscriber.topic_name,
                                                       get_uri)
      if code == 1
        return subscriber
      else
        raise "registration of subscriber failed: #{message}"
      end
    end

    def add_publisher(publisher)
      code, message, uris = @master.registerPublisher(@caller_id,
                                                      publisher.topic_name,
                                                      publisher.topic_type.type,
                                                      get_uri)
      if code == 1
        @publishers.push(publisher)
        return publisher
      else
        raise "registration of publisher failed: #{message}"
      end
    end

    def unregister_publisher(publisher)
      code, message, val = @master.unregisterPublisher(@caller_id,
                                                       publisher.topic_name,
                                                       get_uri)
      if code == 1
        return publisher
      else
        raise "registration of publisher failed: #{message}"
      end
    end

    def spin_once
      @subscribers.each {|subscriber| subscriber.process_queue}
      @service_servers.each {|service_server| service_server.process_queue}
    end

    def shutdown
      @server.shutdown
      @thread.join
      @publishers.each do |publisher|
        unregister_publisher(publisher)
        publisher.shutdown
      end
      @publishers = nil

      @subscribers.each do |subscriber|
        unregister_subscriber(subscriber)
        subscriber.shutdown
      end
      @subscribers = nil
      @service_servers.each do |service|
        unregister_service_server(service)
        service.shutdown
      end
      @service_servers = nil

    end

  end
end
