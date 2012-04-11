require 'xmlrpc/server'
require 'xmlrpc/client'
require 'timeout'

module ROS
  class TopicManager

    def initialize(caller_id, node)
      @caller_id = caller_id
      @node = node
      @host = "localhost"
      @port = get_available_port
      @server = XMLRPC::Server.new(@port)
      @publishers = []
      @subscribers = []
      @service_servers = []
      @server.set_default_handler do |method, *args|
        p 'call!! unhandled'
        p method
        p *args
        [0, "I DON'T KNOW", 0]
      end

      @server.add_handler('getBusStats') do |caller_id|
        [-1, "stats", 'not implemented yet']
      end

      @server.add_handler('getMasterUri') do |caller_id|
        [1, "master", @node.master_uri]
      end

      @server.add_handler('getSubscriptions') do |caller_id|
        @subscribers.map do |sub|
          [sub.topic_name, sub.topic_type.type_string]
        end
      end

      @server.add_handler('getPublications') do |caller_id|
        @publishers.map do |pub|
          [pub.topic_name, pub.topic_type.type_string]
        end
      end

      @server.add_handler('requestTopic') do |caller_id, topic, protocols|
        message = [0, "I DON'T KNOW", 0]
        for protocol in protocols
          if protocol[0] == 'TCPROS'
            for publisher in @publishers
              if publisher.topic_name == topic
                connection = publisher.add_connection(caller_id)
                connection.start
                message = [1, "OK! WAIT!!!", ['TCPROS',
                                              connection.host,
                                              connection.port]]
              end
            end
          end
        end
        message
      end

      @server.add_handler('shutdown') do |caller_id, msg|
        @node.shutdown
        [1, 'shutdown ok', 0]
      end

      @server.add_handler('getPid') do |caller_id|
        [1, "pid ok", Process.pid]
      end

      @server.add_handler('getBusInfo') do |caller_id|
        info = []
        i = 0
        for publisher in @publishers
          for uri in publisher.get_connected_uri
            info.push(['connection' + i.to_s, uri, 'o', 'TCPROS', publisher.topic_name])
          end
        end
        for subscriber in @subscribers
          for uri in subscriber.get_connected_uri
            info.push(['connection' + i.to_s, uri, 'i', 'TCPROS', subscriber.topic_name])
          end
        end
        [1, "getBusInfo ok", info]
      end

      @server.add_handler('publisherUpdate') do |caller_id, topic, publishers|
        for subscriber in @subscribers
          if subscriber.topic_name == topic
            for publisher_uri in publishers
              if not subscriber.has_connection_with?(publisher_uri)
                subscriber.add_connection(publisher_uri)
              end
            end
          end
          for uri in subscriber.get_connected_uri
            if not publishers.index(uri)
              subscriber.drop_connection(uri)
            end
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
      return port
    end

    def test_serve
      @server.serve
    end

    def get_uri
      "http://" + @host + ":" + @port.to_s + "/"
    end

    def wait_for_service(service_name, timeout_sec)
      begin
        timeout(timeout_sec) do
          while @node.ok?
            master = XMLRPC::Client.new2(@node.master_uri)
            code, message, uri = master.call('lookupService',
                                             @caller_id,
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
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call('registerService',
                           @caller_id,
                           service_server.service_name,
                           service_server.service_uri,
                           get_uri)
      if result[0] == 1
        @service_servers.push(service_server)
      else
        p result[0]
        p result[1]
        p result[2]
        raise 'registerService fail'
      end

    end

    def delete_service_server(service)
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call('unregisterService',
                           @caller_id,
                           service.service_name,
                           service,service_uri)
      if result[0] == 0
        @service_servers.delete(service)
      else
        raise 'unregisterService fail'
      end
    end

    def add_subscriber(subscriber)
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call("registerSubscriber",
                           @caller_id,
                           subscriber.topic_name,
                           subscriber.topic_type.type_string,
                           get_uri)
      if result[0] == 1
        for publisher_uri in result[2]
          subscriber.add_connection(publisher_uri)
        end
        @subscribers.push(subscriber)
        return subscriber
      else
        raise "registration of publisher failed"
      end
    end

    def delete_subscriber(subscriber)
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call("unregisterSubscriber",
                           @caller_id,
                           subscriber.topic_name,
                           get_uri)
      if result[0] == 1
        @subscribers.delete(subscriber)
        return subscriber
      else
        raise "registration of subscriber failed"
      end
    end

    def add_publisher(publisher)
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call("registerPublisher",
                           @caller_id,
                           publisher.topic_name,
                           publisher.topic_type.type_string,
                           get_uri)
      if result[0] == 1
        #        for subscriber_uri in result[2]
        #          publisher.add_connection(subscriber_uri)
        #        end
        @publishers.push(publisher)
        return publisher
      else
        raise "registration of publisher failed"
      end
    end

    def delete_publisher(publisher)
      master = XMLRPC::Client.new2(@node.master_uri)
      result = master.call("unregisterPublisher",
                           @caller_id,
                           publisher.topic_name,
                           get_uri)
      if result[0] == 1
        @publishers.delete(publisher)
        return publisher
      else
        raise "registration of publisher failed"
      end
    end

    def spin_once
      for subscriber in @subscribers
        subscriber.process_queue
      end
      for service_server in @service_servers
        service_server.process_queue
      end
    end

    def shutdown
      @publishers.each do |publisher|
        delete_publisher(publisher)
        publisher.shutdown
      end
      @subscribers.each do |subscriber|
        delete_subscriber(subscriber)
        subscriber.shutdown
      end

      @service_servers.each do |service|
        delete_service_server(service)
        service.shutdown
      end

      @server.shutdown
      @thread.join
    end

  end
end
