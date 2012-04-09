require 'xmlrpc/server'
require 'xmlrpc/client'

module ROS
  class TopicManager

    def initialize(caller_id)
      @caller_id = caller_id
      @port = 12345
      @host = "localhost"
      @server = XMLRPC::Server.new(@port)
      @publishers = {}
      @subscribers = {}
      @server.add_handler('requestTopic') do |caller_id, topic, protocols|
        for protocol in protocols
          if protocol[0] == 'TCPROS'
            if @publishers.has_key(topic)
              connection = @publishers[topic].add_subscriber
              return [1, "OK! WAIT!!!", ['TCPROS',
                                         connection.host,
                                         connection.port]]
            end
          end
        end
        return [0, "I DON'T KNOW", 0]
      end
      @thread = Thread.new do
        @server.serve
      end

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
        @subscribers[subscriber.topic_name] = subscriber
        return subscriber
      else
        raise "registration of publisher failed"
      end
    end

    def delete_subscriber(publisher)
      master = XMLRPC::Client.new2(ENV['ROS_MASTER_URI'])
      result = master.call("unregisterPublisher",
                           @caller_id,
                           publisher.topic_name,
                           get_uri)
      if result[0] == 1
        @publishers.delete(publisher.topic_name)
        return publisher
      else
        raise "registration of publisher failed"
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
        #publisher.add_subscribers(result[2])
        @publishers[publisher.topic_name] = publisher
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
        @publishers.delete(publisher.topic_name)
        return publisher
      else
        raise "registration of publisher failed"
      end
    end

    def spin_once
      @subscribers.each_value do |subscriber|
        subscriber.process_queue
      end
    end

    def shutdown
      @publishers.each_value do |publisher|
        delete_publisher(publisher)
        publisher.shutdown
      end
      @subscribers.each_value do |subscriber|
        delete_subscriber(subscriber)
        subscriber.shutdown
      end

      @server.shutdown
      @thread.join
    end

  end
end
