module Kissbox

  class Service < Gom::Remote::Entry

    Defaults = { }

    attr_reader :path

    class << self
      def oattr *names
        names.each do |name|
          class_eval "def #{name}; @options['#{name}'.to_sym]; end"
        end
      end
    end
    oattr :kissbox_ip, :kissbox_port

    def initialize path, options = {}
      @path = path
      #@options = (Defaults.merge options)
      @options = Defaults.merge(gnode(@path)).merge(options)
      puts "options: #{@options.inspect}"

      @chan = TcpMode.new self

      #@values_sub = Subscription.new(
      #  "#{@path}/values", 
      #  :name => "enttec-dmx", :operations => [:update, :create]
      #)
      #@values_sub.callback = lambda { |*args| value_gnp(*args) }
      #connection.subscribe @values_sub
    end

    def push smell
      @chan.push smell
    end

    # TODO: stuff below belongs to gom-script
    private

    def gnode path
      json = (Gom::Remote.connection.read "#{path}.json")
      (JSON.parse json)["node"]["entries"].select do |entry|
        # 1. select attribute entries
        entry.has_key? "attribute"
      end.inject({}) do |h, a|
        # 2. make it a key, value list
        h[a["attribute"]["name"].to_sym] = a["attribute"]["value"]
        h
      end
    end
  end
end
