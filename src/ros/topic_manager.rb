require 'xmlrpc/server'
require 'xmlrpc/client'

module ROS
  class TopicManager

    def initialize(caller_id)
      @caller_id = caller_id
      @host = "localhost"
      @port = get_available_port
      @server = XMLRPC::Server.new(@port)
      @publishers = []
      @subscribers = []
      @server.set_default_handler do |method, *args|
        p 'call!! unhandled'
        p method
        p *args
        [0, "I DON'T KNOW", 0]
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

    def add_subscriber(subscriber)
      master = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
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
      master = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
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
      master = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
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
      master = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
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
    end

    def shutdown
      for publisher in @publishers
        delete_publisher(publisher)
        publisher.shutdown
      end
      for subscriber in @subscribers
        delete_subscriber(subscriber)
        subscriber.shutdown
      end

      @server.shutdown
      @thread.join
    end

  end
end
